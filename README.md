# SVN Docker
下記の要件を満たすSubversionのDockerコンテナ
- `svn://`のみでなく`http://`のプロトコルでもアクセスしたい
- LDAP認証により、認証統合を実現したい

## 使い方
1. Dockerビルドを行う
    ```bash
    $ docker build -t subversion:latest ./subversion-image
    ```
2. docker-composeを使ってコンテナを立ち上げる
    ```bash
    $ docker-compose up -d
    ```
3. レポジトリの作成
    ```bash
    $ docker exec -it subversion bash
    ...
    subversion$ cd /home/svn/repos
    subversion$ svnadmin create testrepo
    ...
    subversion$ ls testrepo
    README.txt  conf  db  format  hooks  locks
    ```
4. レポジトリへのアクセス
    `localuser.list`に記載されている初期ユーザーは下記になる。これで一旦はアクセスが可能であるが、適宜変更してほしい。
    - ID : admin
    - PW : admin

## LDAPの設定
- 下記のファイルを編集する事でLDAPの設定を行う<br>
    `/usr/local/apache2/conf/extra/svn.conf`
- `docker-compose.yaml`の中身を見ていただくと分かる通り、このファイルはホストOSにマウントされているのでホストOS側から直接編集してもよい# subversion-docker

https://www.engilaboo.com/apache-docker-https/
https://LAPTOP-GFO0OHTD

自己証明書の作成
秘密鍵を作成
~~~
openssl genrsa -aes128 2048 > server.key
~~~

~~~
openssl req -new -key server.key > server.csr
~~~
Country Name -> JP
Common name -> IPアドレス or FQDN形式のホスト名

server.crt（サーバ証明書）の作成
~~~
openssl x509 -in server.csr -days 365 -req -signkey server.key > server.crt
~~~

パスワードの解除
~~~
mv server.key server.key.org
openssl rsa -in server.key.org > server.key
~~~

HTTPS強制
~~~
RewriteEngine on
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
~~~

http.confのSSL関連モジュールの有効化
~~~
RUN sed -i -e 's,#LoadModule socache_shmcb_module modules/mod_socache_shmcb.so,LoadModule socache_shmcb_module modules/mod_socache_shmcb.so,g' /usr/local/apache2/conf/httpd.conf
RUN sed -i -e 's,#LoadModule ssl_module modules/mod_ssl.so,LoadModule ssl_module modules/mod_ssl.so,g' /usr/local/apache2/conf/httpd.conf
~~~

