defmodule Revstack.Accounts.User.Senders.SendPasswordResetEmail do
  @moduledoc """
  Sends a password reset email
  """

  use AshAuthentication.Sender
  use RevstackWeb, :verified_routes

  import Swoosh.Email
  alias Revstack.Mailer

  @impl true
  def send(user, token, _) do
    email =
      case user do
        %{email: email} -> email
        email -> email
      end

    new()
    |> from({"RevenueLink Technologies", "noreply@revenuelink.net"})
    |> to(to_string(email))
    |> subject("Reset your password")
    |> html_body(body(token: token, email: email))
    |> Mailer.deliver!()
  end

  defp body(params) do
    """
    <p>Hello, #{params[:email]}!</p>
    <p>Someone requested a password reset for your account. If this was you, click the link below:</p>
    <p><a href="#{url(~p"/password-reset/#{params[:token]}")}">Reset Password</a></p>
    <p>If you did not request this, you can safely ignore this email.</p>
    """
  end
end
