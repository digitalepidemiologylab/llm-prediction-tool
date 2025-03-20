# frozen_string_literal: true

RSpec::Matchers.define_negated_matcher(:not_change, :change)
RSpec::Matchers.define_negated_matcher(:not_have_enqueued_job, :have_enqueued_job)
RSpec::Matchers.define_negated_matcher(:not_raise_error, :raise_error)
