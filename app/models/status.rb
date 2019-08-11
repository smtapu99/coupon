class Status < ActiveEnum::Base
  value name: 'active', id: 'active'
  value name: 'blocked', id: 'blocked'
  value name: 'pending', id: 'pending'
end
