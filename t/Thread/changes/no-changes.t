use jmaptest;

test {
  my ($self) = @_;

  my $account = $self->any_account;
  my $tester  = $account->tester;

  my $message = $account->create_mailbox->add_message;

  my $state = $account->get_state('thread');

  my $res = $tester->request([[
    "Thread/changes" => { sinceState => $state, },
  ]]);
  ok($res->is_success, "Thread/changes")
    or diag explain $res->response_payload;

  my $changes = $res->single_sentence("Thread/changes")->arguments;

  jcmp_deeply(
    $changes,
    {
      accountId      => jstr($account->accountId),
      oldState       => jstr($state),
      newState       => jstr($state),
      hasMoreChanges => jfalse,
      created        => [],
      updated        => [],
      destroyed      => [],
    },
    "Response looks good",
  ) or diag explain $res->as_stripped_triples;
};
