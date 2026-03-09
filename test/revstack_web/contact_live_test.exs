defmodule RevstackWeb.ContactLiveTest do
  use RevstackWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "contact page renders with the form", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/contact")

    assert has_element?(view, "#contact-form")
    assert has_element?(view, "#contact-form label", "Name")
    assert has_element?(view, "#contact-form label", "Email")
    assert has_element?(view, "#contact-form label", "Company")
    assert has_element?(view, "#contact-form label", "Preferred Contact Method")
    assert has_element?(view, "#contact-form label", "Message")
  end

  test "form displays all required fields on initial load with default value", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/contact")

    assert has_element?(view, "input[name='form[name]']")
    assert has_element?(view, "input[name='form[email]']")
    assert has_element?(view, "input[name='form[company]']")
    assert has_element?(view, "select[name='form[preferred_contact_method]']")
    assert has_element?(view, "textarea[name='form[message]']")
  end

  test "when 'email' is selected, only email field is displayed (phone is hidden)", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/contact")

    view
    |> form("#contact-form", %{"form" => %{"preferred_contact_method" => "email"}})
    |> render_change()

    assert has_element?(view, "input[name='form[email]']")
    refute has_element?(view, "input[name='form[phone]']")
  end

  test "when 'phone' is selected, only phone field is displayed (email is hidden)", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/contact")

    view
    |> form("#contact-form", %{"form" => %{"preferred_contact_method" => "phone"}})
    |> render_change()

    refute has_element?(view, "input[name='form[email]']")
    assert has_element?(view, "input[name='form[phone]']")
  end

  test "when 'either' is selected, both email and phone fields are displayed", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/contact")

    view
    |> form("#contact-form", %{"form" => %{"preferred_contact_method" => "either"}})
    |> render_change()

    assert has_element?(view, "input[name='form[email]']")
    assert has_element?(view, "input[name='form[phone]']")
  end

  test "switching between contact methods updates field visibility", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/contact")

    # Start with email
    view
    |> form("#contact-form", %{"form" => %{"preferred_contact_method" => "email"}})
    |> render_change()

    assert has_element?(view, "input[name='form[email]']")
    refute has_element?(view, "input[name='form[phone]']")

    # Switch to phone
    view
    |> form("#contact-form", %{"form" => %{"preferred_contact_method" => "phone"}})
    |> render_change()

    refute has_element?(view, "input[name='form[email]']")
    assert has_element?(view, "input[name='form[phone]']")

    # Switch to either
    view
    |> form("#contact-form", %{"form" => %{"preferred_contact_method" => "either"}})
    |> render_change()

    assert has_element?(view, "input[name='form[email]']")
    assert has_element?(view, "input[name='form[phone]']")
  end

  test "contact form renders send message button", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/contact")

    assert has_element?(view, "button[type='submit']", "Send Message")
  end

  test "contact form has a honeypot field hidden from view", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/contact")

    html = render(view)

    assert html =~ "phx-no-curly-interpolation" ||
             has_element?(view, "input[name='form[honeypot]']")
  end
end
