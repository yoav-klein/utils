
"""
update nameservers in GoDaddy
"""

import requests
import json


def main():
    key = "fZ1WmSYSs5fD_BSaytqeAfrVWPE3LmBPtJ5"
    secret = "6mw7L9wcBeaKRr5btg7H5y"
    url="https://api.godaddy.com/v1/domains/dikla-klein.com"
    
    headers = {
        "Authorization": f"sso-key {key}:{secret}"
    }
    resp = json.loads(requests.get(url, headers=headers).text)  
    nameservers = resp['nameServers']
    new = {
        'nameServers': 
        [
            'ns-1956.awsdns-52.co.uk', 
            'ns-65.awsdns-08.com', 
            'ns-1530.awsdns-63.org', 
            'ns-914.awsdns-50.net'
        ]
    }
    
    resp = requests.patch(url, headers=headers, json=new)
    resp.raise_for_status()

    print(resp.status_code)
    print(resp.text)

if __name__ == "__main__":
    main()
