# app/controllers/concerns/response.rb
module Response
  def json_response(object, status = :ok)
    render json: object, status: status
  end

  def bad_request(message = 'bad request')
    json_response({message: message}, :bad_request)
  end

  def not_found(message = 'not found')
    json_response({message: message}, :not_found)
  end

  def forbidden(message = 'forbidden')
    json_response({message: message}, :forbidden)
  end
end
