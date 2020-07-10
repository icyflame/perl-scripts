#!/usr/bin/env perl

=pod
algolia-storage-monitor.pl

This script prints the time remaining until a single Algolia index reaches the
storage limit of 100 GB.

https://www.algolia.com/doc/guides/sending-and-managing-data/prepare-your-data/in-depth/index-and-records-size-and-usage-limitations/#size-limits

Example:

$ PERL_LWP_SSL_VERIFY_HOSTNAME=0 \
    SLACK_NOTIFICATIONS_URL='' \
    ALGOLIA_USAGE_API_KEY=abc \
    ALGOLIA_APP_ID=def \
    ALGOLIA_INDEX_NAME=ghi \
    perl script/algolia-storage-monitor.pl
=cut

use strict;
use warnings;

use JSON;
use LWP::UserAgent;
use DateTime;
use Text::Table;
use Number::Format qw(format_number);

use Env qw(
	ALGOLIA_USAGE_API_KEY
    ALGOLIA_APP_ID
    ALGOLIA_INDEX_NAME
	SLACK_NOTIFICATIONS_URL
	);

use constant LISTINGS_PER_DAY => 380000;

# 100 GB
use constant MAX_STORAGE_SIZE => 100 * 1000 * 1000 * 1000;

use constant DATE_FORMAT => "hh:mm a dd MMM yyyy zzz";

my $now = DateTime->now();

sub algolia_application_status {
	my ($app_id, $api_key, $index) = @_;

	# Find usage metrics for this cluster
	# https://www.algolia.com/doc/rest-api/usage/#get-usage-index
	my $resp = LWP::UserAgent->new->get("https://usage.algolia.com/1/usage/file_size,records/period/day/$index",
										"X-Algolia-Application-Id" => $app_id,
										"X-Algolia-API-Key" => $api_key);

	die "request failed: " . $resp->status_line unless $resp->is_success;
	decode_json($resp->decoded_content);
}

sub get_days_to_go {
	my $results = algolia_application_status(@_);

	# Algolia timestamps are milliseconds from epoch
	my $data_ts = $results->{'file_size'}[0]->{'t'} / 1000;
	my $index_size = $results->{'file_size'}[0]->{'v'};
	my $num_records = $results->{'records'}[0]->{'v'};

	my $bytes_per_record = $index_size / $num_records;

	my $records_to_go = (MAX_STORAGE_SIZE - $index_size) / $bytes_per_record;

	my $days_to_go = $records_to_go / LISTINGS_PER_DAY;

	($days_to_go, $records_to_go, $index_size, $num_records, $data_ts);
}

sub build_message {
	my ($days_to_go, $records_to_go, $index_size, $num_records, $data_ts) = get_days_to_go(@_);

	my $data_source_ts = DateTime->from_epoch(epoch => $data_ts);
	$data_source_ts->set_time_zone("Asia/Tokyo");
	my $data_source_jst = $data_source_ts->format_cldr(DATE_FORMAT);

	my $storage_reach_date = DateTime->from_epoch(epoch => $data_ts);
	$storage_reach_date->add(days => $days_to_go);

	$storage_reach_date->set_time_zone("Asia/Tokyo");
	my $end_date_jst = $storage_reach_date->format_cldr(DATE_FORMAT);

	$storage_reach_date->set_time_zone("America/Los_Angeles");
	my $end_date_pdt = $storage_reach_date->format_cldr(DATE_FORMAT);

	my $tb = Text::Table->new(\'| ', "
&left", \' | ', "
&right" , \' |');

	$tb->add('--', '--');
	$tb->add("End Date (JST)", $end_date_jst);
	$tb->add("End Date (PDT)", $end_date_pdt);

	$tb->add("--", "--");
	$tb->add("Days to go", format_number(int($days_to_go)));
	$tb->add("Records to go", format_number(int($records_to_go)));

	$tb->add('--', '--');
	$tb->add("Current index size", format_number($index_size / 1000 / 1000 / 1000) . " GB");
	$tb->add("Current number of records", format_number(int($num_records)));
    $tb->add('--', '--');
    $tb->add("Listings per day (estimated)", format_number(LISTINGS_PER_DAY));

	$tb->add('--', '--');
	$tb->add("Timestamp of data collection", $data_source_jst);

	$tb;
}

my $message = build_message($ALGOLIA_APP_ID, $ALGOLIA_USAGE_API_KEY, $ALGOLIA_INDEX_NAME);
print $message;

if ($SLACK_NOTIFICATIONS_URL ne "") {
    my $resp = LWP::UserAgent->new->post($SLACK_NOTIFICATIONS_URL, Content => "{\"text\":\"```$message```\"}", "content-type" => "application/json");
    die "request failed: " . $resp->status_line unless $resp->is_success;
    print $resp;
}
