# frozen_string_literal: true

require 'http'

class EnomClient
  def initialize(username = nil, password = nil); end

  def search_keywords(search=nil)
    url = 'https://resellertest.enom.com/interface.asp'

    tld_list = ['com', 'net', 'org', 'us']

    params = {
      UID: Rails.application.credentials.enom[:username],
      PW: Rails.application.credentials.enom[:password],
      OnlyTldList: tld_list,
      COMMAND: 'GETNAMESUGGESTIONS',
      SearchTerm: search,
      MaxResults: 50,
      ResponseType: 'XML'
    }
    res = HTTP.get(url, params: params).body.to_s
    res = Hash.from_xml(res)
    puts '***'*25
    puts res
    res.dig 'interface_response', 'DomainSuggestions', 'Domain'
  end

  def register_domain(domain, user)
    url = 'https://resellertest.enom.com/interface.asp'
    params = {
      UID: Rails.application.credentials.enom[:username],
      PW: Rails.application.credentials.enom[:password],
      SLD: domain.split('.').first,
      TLD: domain.split('.').last,
      COMMAND: 'Purchase',
      RegistrantOrganizationName: 'KINGDOM',
      RegistrantFirstName: user.full_name.split(' ').first,
      RegistrantLastName: user.full_name.split(' ').last,
      RegistrantAddress1: 'California',
      RegistrantCity: 'Hometown',
      RegistrantStateProvince: 'WA',
      RegistrantStateProvinceChoice: 'S',
      RegistrantPostalCode: '98003',
      RegistrantCountry: 'United States',
      RegistrantEmailAddress: 'mzubair@boxdevlab.com',
      RegistrantPhone: user.phone_number || '',
      ResponseType: 'XML'
    }

    res = HTTP.get(url, params: params).body.to_s
    Hash.from_xml(res)
  end
end
