defmodule Revstack.MixProjectTest do
  use ExUnit.Case, async: true

  test "assets.sync copies the resume only into priv/resume" do
    aliases = Revstack.MixProject.project()[:aliases]
    sync_alias = aliases[:"assets.sync"]

    assert "cmd mkdir -p priv/resume" in sync_alias

    assert "cmd cp assets/resume/kyle-neal-resume.pdf priv/resume/kyle-neal-resume.pdf" in sync_alias

    refute Enum.any?(sync_alias, &String.contains?(&1, "priv/static/resume"))
  end
end
