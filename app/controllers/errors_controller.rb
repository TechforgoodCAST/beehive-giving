class ErrorsController < ApplicationController
  def forbidden
    render_template(403)
  end

  def not_found
    render_template(404)
  end

  def gone
    render_template(410)
  end

  def internal_server_error
    render_template(500)
  end

  private

    def render_template(status)
      respond_to do |format|
        format.html { render status: status }
        format.js { render js: "window.location.href = '/#{status}';" }
      end
    end
end
