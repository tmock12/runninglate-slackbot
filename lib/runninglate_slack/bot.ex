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
    respond_to_slack(%{
      text: response.text,
      slackit: text_contains_timeout(response.text) && response.channel != @timeout_channel,
      slack: slack,
      response: response
    })
    {:ok, state}
  end

  def handle_message(_message, _slack, state) do
    {:ok, state}
  end

  def respond_to_slack(%{text: text, slackit: true, slack: slack, response: response}) do
    get_username(response.user, slack)
    |> generate_response(response.text)
    |> Slack.send_message(@timeout_channel, slack)
  end

  def respond_to_slack(%{slackit: false}) do
    {:ok}
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

  def text_contains_timeout(text) do
    String.downcase(text)
    |> String.contains?(possible_running_late_messages)
  end
end
