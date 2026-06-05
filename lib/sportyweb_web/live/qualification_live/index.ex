defmodule SportywebWeb.QualificationLive.Index do
  use SportywebWeb, :live_view

  alias Sportyweb.Personal
  alias Sportyweb.Personal.Qualification

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :qualifications, Personal.list_qualifications())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Qualification")
    |> assign(:qualification, Personal.get_qualification!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Qualification")
    |> assign(:qualification, %Qualification{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Qualifications")
    |> assign(:qualification, nil)
  end

  @impl true
  def handle_info({SportywebWeb.QualificationLive.FormComponent, {:saved, qualification}}, socket) do
    {:noreply, stream_insert(socket, :qualifications, qualification)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    qualification = Personal.get_qualification!(id)
    {:ok, _} = Personal.delete_qualification(qualification)

    {:noreply, stream_delete(socket, :qualifications, qualification)}
  end
end
