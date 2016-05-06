class RanksDatatable
  include AjaxDatatablesRails::Extensions::Kaminari

  delegate :params, :link_to, to: :@view

  def initialize view
    @view = view
  end

  def as_json options = {}
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Rank.count,
      iTotalDisplayRecords: ranks.total_count,
      aaData: data
    }
  end

  private
  def data

    ranks.each_with_index.map do |rank, index|
      [
        index + 1,
        rank.rank_value,
        rank.begin_point,
        rank.end_point,
        link_to(@view.t("button.edit"), @view.edit_admin_rank_path(rank), class: "text-primary pull-right"),
        link_to(@view.t("button.delete"), @view.admin_rank_path(rank),
          method: :delete, data: {confirm: @view.t("messages.delete.confirm")}, class: "text-danger pull-right")
      ]
    end
     # binding.pry
  end

  def ranks
    @ranks ||= fetch_ranks
  end

  def fetch_ranks
    ranks = Rank.order "#{sort_column} #{sort_direction}"
    ranks = ranks.per_page_kaminari(page).per per_page
    if params[:sSearch].present?
      ranks = ranks.where "rank_value like :search", search: "%#{params[:sSearch]}%"
    end
    ranks
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[rank_value]
    columns[params[:iSortCol_1].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
