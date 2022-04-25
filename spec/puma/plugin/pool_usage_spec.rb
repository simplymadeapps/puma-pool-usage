# frozen_string_literal: true

RSpec.describe "Puma Pool Usage" do
  subject do
    # starting in Puma 5.x, the new method no longer takes any arguments
    Puma::Plugins.find("pool_usage").new
  rescue ArgumentError
    Puma::Plugins.find("pool_usage").new(Puma::Plugin)
  end

  before do
    Rails.logger = Logger.new($stdout)
  end

  describe "Registration" do
    it "registers plugin with puma" do
      expect(Puma::Plugins.find("pool_usage")).to be_a(Class)
    end
  end

  describe "start" do
    let(:launcher) { double("launcher") }

    it "passes our block of work to `in_background`" do
      stub_const("ENV", ENV.to_hash.merge("PUMA_STATS_FREQUENCY" => "30"))

      expect_any_instance_of(Puma::Plugin).to receive(:in_background) do |&block|
        expect(subject).to receive(:loop).and_yield
        expect(subject).to receive(:sleep).with(30).and_return(true)
        expect(subject).to receive(:find_and_log_pool_usage)
        expect(Rails.logger).to receive(:flush).once
        block.call
      end
      subject.start(launcher)
    end
  end

  describe "find_and_log_pool_usage" do
    let(:cluster_stats) do
      {
        worker_status: [
          { last_status: { backlog: 0, pool_capacity: 4, running: 5 }, pid: 111 },
          { last_status: { backlog: 0, pool_capacity: 3, running: 5 }, pid: 222 }
        ]
      }
    end
    let(:single_stats) do
      { backlog: 0, pool_capacity: 3, running: 5 }
    end

    context "when in single mode" do
      before do
        expect(Puma).to receive(:stats).once.and_return(JSON.generate(single_stats))
      end

      it "calls log_pool_usage once with statistics" do
        expect(subject).to receive(:log_pool_usage).once.with(
          hash_including(backlog: 0, pool_capacity: 3, running: 5),
          pid: 0
        )
        subject.send(:find_and_log_pool_usage)
      end
    end

    context "when in cluster mode" do
      before do
        expect(Puma).to receive(:stats).once.and_return(JSON.generate(cluster_stats))
      end

      it "calls log_pool_usage once with statistics" do
        expect(subject).to receive(:log_pool_usage).once.with(
          hash_including(backlog: 0, pool_capacity: 4, running: 5),
          pid: 111
        )
        expect(subject).to receive(:log_pool_usage).once.with(
          hash_including(backlog: 0, pool_capacity: 3, running: 5),
          pid: 222
        )
        subject.send(:find_and_log_pool_usage)
      end
    end
  end

  describe "log_pool_usage" do
    it "logs source as PUMA" do
      expect(Rails.logger).to receive(:info).with(/source=PUMA/)
      subject.send(:log_pool_usage, { backlog: 0, pool_capacity: 5, running: 5 }, pid: 333)
    end

    it "logs pid" do
      expect(Rails.logger).to receive(:info).with(/pid=333/)
      subject.send(:log_pool_usage, { backlog: 0, pool_capacity: 5, running: 5 }, pid: 333)
    end

    it "logs pool usage as 0.0 (0%) when no requests" do
      expect(Rails.logger).to receive(:info).with(/sample#pool_usage=0.0/)
      subject.send(:log_pool_usage, { backlog: 0, pool_capacity: 5, running: 5 }, pid: 333)
    end

    it "logs pool usage as 1.0 (100%) when all workers are busy" do
      expect(Rails.logger).to receive(:info).with(/sample#pool_usage=1.0/)
      subject.send(:log_pool_usage, { backlog: 0, pool_capacity: 0, running: 5 }, pid: 333)
    end

    it "logs pool usage as 1.2 (120%) when all workers are busy and a backlog exists" do
      expect(Rails.logger).to receive(:info).with(/sample#pool_usage=1.2/)
      subject.send(:log_pool_usage, { backlog: 1, pool_capacity: 0, running: 5 }, pid: 333)
    end

    it "does not logging if Puma has not yet started, which results in empty stats" do
      expect(Rails.logger).not_to receive(:info)
      subject.send(:log_pool_usage, {}, pid: 0)
    end
  end
end
