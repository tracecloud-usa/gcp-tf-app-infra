---
username: trace
ansible_host: ${public_ip}
ssh_pubkey: ~/.ssh/id_rsa.pub
domain: ${domain}
website_files:
%{ for file in website_files ~}
    - ${file}
%{ endfor ~}
host: ${host}