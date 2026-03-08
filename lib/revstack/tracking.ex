defmodule Revstack.Tracking do
  use Ash.Domain, otp_app: :revstack, extensions: [AshAdmin.Domain]

  admin do
    show?(true)
  end

  resources do
    resource Revstack.Tracking.Visitor
    resource Revstack.Tracking.VisitorPageVisit
  end
end
