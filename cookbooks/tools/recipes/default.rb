package 'nodejs' do
  version node['tools']['nodejs']['version']
end

package 'npm' do
  version node['tools']['npm']['version']
end

nodejs_npm "mountebank"
