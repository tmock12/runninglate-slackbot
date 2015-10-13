defmodule RunninglateSlack.Bot do
  use Slack

  @timeout_channel "C0AQW73S9"
  @chicago_channel "C02AY1U8W"
  @jax_channel "C02B0NRFL"
  @timeout_bot "U0BP6UF33"

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
      slackit: slackit(response),
      slack: slack,
      response: response,
      channel: response.channel
    })
    {:ok, state}
  end

  def handle_message(_message, _slack, state) do
    {:ok, state}
  end

  def slackit(response) do
    text_contains(response.text, possible_running_late_messages)
    && response.channel != @timeout_channel
    && response.user != @timeout_bot
  end

  def post_to_slack_channels([head|tail], message, slack) do
    case head do
      {:chi, true} ->
        Slack.send_message(message, @chicago_channel, slack)
        post_to_slack_channels(tail, message, slack)
      {:jax, true} ->
        Slack.send_message(message, @jax_channel, slack)
        post_to_slack_channels(tail, message, slack)
      _ ->
        post_to_slack_channels(tail, message, slack)
    end
  end

  def post_to_slack_channels([], _message, _slack) do
    {:ok}
  end

  def respond_to_slack(%{response: response, channel: @timeout_channel, slack: slack}) do
    message = get_username(response.user, slack)
              |> generate_response(response.text)

    regional_channels(response.text)
    |> post_to_slack_channels(message, slack)
  end

  def respond_to_slack(%{text: text, slackit: true, slack: slack, response: response}) do
    get_username(response.user, slack)
    |> generate_response(response.text)
    |> Slack.send_message(@timeout_channel, slack)
  end

  def respond_to_slack(%{slackit: false}) do
    {:ok}
  end

  def regional_channels(message) do
    [chi: text_contains(message, chi_channel_tags), jax: text_contains(message, jax_channel_tags)]
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
      "running late",
      "time-out"
    ])
  end

  def jax_channel_tags do
    :binary.compile_pattern([
      "jax",
      "jacksonville"
    ])
  end

  def chi_channel_tags do
    :binary.compile_pattern([
      "chi",
      "chicago"
    ])
  end

  def text_contains(text, match) do
    String.downcase(text)
    |> String.contains?(match)
  end

end
