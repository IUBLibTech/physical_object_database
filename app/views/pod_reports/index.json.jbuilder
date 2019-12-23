json.array!(@pod_reports) do |pod_report|
  json.extract! pod_report, :id, :status, :filename
  json.url pod_report_url(pod_report, format: :json)
end
