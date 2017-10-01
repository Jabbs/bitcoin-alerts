module ApplicationHelper
  def page_id
    page = "page"
    controller_ary = params[:controller].split("/")
    controller_ary.each do |c|
      page << "-#{c}"
    end
    page << "-#{action_name}"
  end

  def show_svg(path)
    File.open("app/assets/images/coins/#{path}", "rb") do |file|
      raw file.read
    end
  end
end
