defmodule Loom.Tools.PeerCompleteTask do
  @moduledoc "Agent-initiated task completion."

  use Jido.Action,
    name: "peer_complete_task",
    description:
      "Mark a task as completed with an optional result summary. " <>
        "Broadcasts task_completed so the team knows the task is done.",
    schema: [
      team_id: [type: :string, required: true, doc: "Team ID"],
      task_id: [type: :string, required: true, doc: "ID of the task to complete"],
      result: [type: :string, doc: "Result summary or output of the completed task"]
    ]

  import Loom.Tool, only: [param!: 2, param: 2]

  alias Loom.Teams.Tasks

  @impl true
  def run(params, _context) do
    _team_id = param!(params, :team_id)
    task_id = param!(params, :task_id)
    result = param(params, :result) || ""

    case Tasks.complete_task(task_id, result) do
      {:ok, task} ->
        summary = """
        Task completed:
          ID: #{task.id}
          Title: #{task.title}
          Status: #{task.status}
        """

        {:ok, %{result: String.trim(summary), task_id: task.id}}

      {:error, reason} ->
        {:error, "Failed to complete task: #{inspect(reason)}"}
    end
  end
end
