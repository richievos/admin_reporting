# Admin Reporting #
This Rails engine is based on a really interesting article on metrics those running a site should be checking out:  http://www.watchingwebsites.com/archives/lean-analytics-questions-vcs-should-ask-and-youd-better-answer. After reading that I started implementing them on http://reeflines.com. The general concept is you define a report as a structure that looks like so:

    {
      'data set description' => [
                                  %w(header1 header2 header3),
                                  [col1_data, col2_data, col3_data],
                                  [col1_data, col2_data, col3_data],
      ],
      'another data set' => ...
    }

In other words, a hash where each data set points to a table of data.

This feels like a pretty straightforward way to separate the data, and it's easy to make this into html tables or csvs or whatever tabular structure.

## Usage ##
This is a rails engine that adds a single _report_ resource in the admin namespace:

    /admin/reports/report_name

Right off the bat you're given an "engagement" report (see the article to see what they define that to be) which is available at /admin/reports/engagement.

### Adding reports ###
To add your own report, in config/initializers/reports.rb (or somewhere in your initialization), do the following:

    AdminReporting.configure do |config|
      config.reports do
        report "login_names" do |data|
          # data is the variable where your data set should be stored:

          headers = ['login', 'email']
          data = User.all.map { |user| [user.login, user.email] }
          data['user names'] = [headers] + data
        end
      end
    end

Then to view that report (after restarting your server), go to /admin/reports/login_names

### Customizing the controller ###
The first step after you install this plugin should be customizing your controller, adding in your admin security. To do this, in your same initializer, add a config.controller block:

    AdminReporting.configure do |config|
      config.reports {}

      # acl9 example
      config.controller do
        access_control do
          allow :admin
        end

        layout 'site'
      end
    end

This is just doing a class_eval on a Admin::ReportsController < ApplicationController, so you can do any controller magic you want. The report itself is generated in the show action.

### Other Setup ###
I'd recommend getting the following into the view as part of a layout:

    <%= javascript_include_tag "jquery/jquery.tablesorter" %>
    <%= stylesheet_link_tag 'jquery/blue/style' %>

    <script>
    $(function() {
      $('table').tablesorter()
    })
    </script>

    <style>
      table td, table th {
        padding-left: 10px;
        padding-right: 20px;
      }

      table td:first-child, table th:first-child {
        padding-left: 0;
      }

      ul.navigation {
        padding: 0;
      }

      ul.navigation li {
        display: inline;
        margin: 0 5px;
        font-size: 1.5em;
      }
    </style>

That should give you a nice looking table and sortability using the tablesorter plugin.

If you somewhere have a :head block in your views, the above code will automatically be included into it (ie by default that code is in a content_for :head block).

Originally created by Richie Vos
http://github.com/jerryvos
http://esopp.us
http://reeflines.com