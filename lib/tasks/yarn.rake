# XXX: monkey patch for GAE deployments to ensure yarn:install gets triggered
# TODO: remove entire task when Webpacker reaches satisfactory solution for Rails >=5.1
# See https://github.com/rails/webpacker/issues/810
namespace :yarn do
  desc "Install all JavaScript dependencies as specified via Yarn"
  task :install do
    # Install only production deps when for not usual envs.
    valid_node_envs = %w[test development production]
    node_env = ENV.fetch("NODE_ENV") do
      rails_env = ENV["RAILS_ENV"]
      valid_node_envs.include?(rails_env) ? rails_env : "production"
    end
    system({ "NODE_ENV" => node_env }, "yarn install --no-progress")
  end
end
