defmodule RunninglateSlack.Bot do
  use Slack

  @timeout_channel "C0AQW73S9"

  def start_link(initial_state) do
    Slack.start_link(__MODULE__, System.get_env("SLACK_BOT"), initial_state)
  end

  def init(initial_state, slack) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, initial_state}
  end

  def handle_message({:type, "hello", response}, slack, state) do
    {:ok, state}
  end

  def handle_message({:type, "message", response}, slack, state) do
    unless response.channel == @timeout_channel do
      if String.contains?("#{inspect response.text}", possible_running_late_messages) do
        get_username(response.user, slack)
        |> generate_response(response.text)
        |> Slack.send_message(@timeout_channel, slack)
      end
    end
    {:ok, state}
  end

  def handle_message(_message, _slack, state) do
    {:ok, state}
  end

  def get_username(id, slack) do
    Slack.State.users(slack)[String.to_atom(id)].name
  end

  def generate_response(username, text) do
    "@#{username} said: #{text}"
  end

  def possible_running_late_messages do
    :binary.compile_pattern([
      "timeout",
      "time out",
      "running late"
    ])
  end
end
