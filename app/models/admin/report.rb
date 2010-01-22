module Admin
  class Report
    begin
      include MongoMapper::Document

      key :name, String
      key :data, Hash

      timestamps!
    rescue
      attr_accessor :name, :data

      def data
        @data ||= {}
      end

      def save
        false
      end
    end

    unloadable

    def self.reports
      @reports ||= {}
    end

    def self.report(name, &block)
      reports[name] = block
    end

    def self.build(name)
      block = @reports[name] or raise "No report named #{name} found"

      rep = new(:name => name)
      block.call(rep.data)
      rep
    end

    def self.run(name)
      returning(build(name)) do |rep|
        rep.save
      end
    end

    def self.report_names
      reports.keys
    end

    def self.percent(number)
      BigDecimal.new((number * 100).to_s).round(1)
    end

    # this report requires User to have created_since and a scope for each passed in scope
    def self.signup_report(*scopes_to_try)
      report "signups" do |data|
        total_user_count = User.count
        sets_of_interest = Proc.new do |*args|
          type, scope = args
          scope ||= User.send(type)

          type = type.titleize
          params = ["#{User.table_name}.id", {:distinct => true}]
          count = scope.count(*params)

          now = Time.zone.now
          [type, count, count / total_user_count.to_f * 100, scope.created_since(now.beginning_of_day).count(*params), scope.created_since(now.beginning_of_week).count(*params)]
        end
        data['user counts'] = [['type', 'total', 'percentage', 'today', 'this week'],
                               sets_of_interest.call('all', User),
                               *scopes_to_try.map { |scope| sets_of_interest.call(scope)} ] 
      end
    end

    # this report requires User to have active_between and logged_in_between
    report "engagement" do |data|
      total_user_count = User.count.to_f
      # + 2.seconds to avoid weirdness where db precision results in ignoring this (and simultaneous) requests
      now = Time.zone.now + 2.seconds
      buckets = (1..9).map do |i|
        duration = i.days
        ["#{duration.inspect} ago", now - i.days]
      end

      disengaged_count = User.active_between(Time.zone.local(2009, 1, 1), now - 10.days).count
      headers = ["Time", "Count", "Percentage"]
      data['used the app'] = [headers] + 
        buckets.map do |(title, start)|
          count = User.active_between(start, start + 1.day).count
          [title, count, percent(count / total_user_count)]
        end +
        [["Disengaged", disengaged_count, percent(disengaged_count/ total_user_count)]]

      headers = ["Time", "Count", "Percentage"]
      data['logged in'] = [headers] + 
        buckets.map do |(title, start)|
          count = User.logged_in_between(start, start + 1.day).count
          [title, count, percent(count / total_user_count)]
        end
    end
  end
end
# hackervision: need to rerun any configuration that was set since it would have
# been removed during class reloading
AdminReporting.configuration.load_config("reports")