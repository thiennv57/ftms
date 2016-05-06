class EvaluationTemplatesDatatable
  include AjaxDatatablesRails::Extensions::Kaminari

  delegate :params, :link_to, to: :@view

  def initialize view
    @view = view
  end

  def as_json options = {}
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: EvaluationTemplate.count,
      iTotalDisplayRecords: evaluation_templates.total_count,
      aaData: data
    }
  end

  private
  def data
    evaluation_templates.each_with_index.map do |evaluation_template, index|
      [
        index + 1,
        evaluation_template.name,
        evaluation_template.min_point,
        evaluation_template.max_point,
        link_to(@view.t("button.edit"), @view.edit_admin_evaluation_template_path(evaluation_template),
          class: "text-primary pull-right"),
        link_to(@view.t("button.delete"),
          @view.admin_evaluation_template_path(evaluation_template),
          method: :delete, data: {confirm: @view.t("messages.delete.confirm")},
          class: "text-danger pull-right")
      ]
    end
  end

  def evaluation_templates
    @evaluation_templates ||= fetch_evaluation_templates
  end

  def fetch_evaluation_templates
    evaluation_templates = EvaluationTemplate.order "#{sort_column} #{sort_direction}"
    evaluation_templates = evaluation_templates.per_page_kaminari(page).per per_page
    if params[:sSearch].present?
      evaluation_templates = evaluation_templates.where "name like :search", search: "%#{params[:sSearch]}%"
    end
    evaluation_templates
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[name]
    columns[params[:iSortCol_1].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
