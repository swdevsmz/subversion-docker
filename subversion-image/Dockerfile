# http/httpsのプロトコルで通信を行うため、Subversionの他にApache-Httpdが含まれるコンテナイメージを構築する。
# 正確には、Apache-HttpdのコンテナにSubversionをInstallするのだが、
# "httpd"という名称でApacheから公式イメージが提供されているのでそれを使用する
# https://hub.docker.com/_/httpd/tags
FROM httpd:latest

# SubversionのInstall
# libapache2-mod-svn（SVNとApacheの連携を行い、複数ユーザーがApache経由でリポジトリとやり取りするためのモジュール）のInstall
RUN apt update && apt install -y \
	libapache2-mod-svn subversion-tools sudo vim \
	subversion --no-install-recommends &&\
	apt clean

# リポジトリ用のディレクトリを作成
RUN	mkdir -p /home/svn/repos &&\
    mkdir -p /run/apache2/ &&\
	mkdir -p /etc/subversion &&\
	touch /etc/subversion/passwd

# LDAP認証ができない場合に備え、ローカルユーザーでもアクセスできるようにユーザー名＋パスワードのファイルを作成し、初期ユーザーを登録
# 初期ユーザーはID:admin, Pass:admin、パスワードはMD5形式で保存されている
COPY localuser.list /home/svn/localuser.list
# httpd（Apache）をフォアグラウンドで起動するシェルスクリプトを/etc/services.d/apache/配下にコピー
COPY apache/ /etc/services.d/apache/
# svnserve（svnのプロトコルでリポジトリにアクセス）のプロセスを起動する為のシェルスクリプトを/etc/services.d/subversion/配下にコピー
COPY subversion/ /etc/services.d/subversion/
# アクセスコントロール定義ファイルのコピー
COPY subversion-access-control /etc/subversion/subversion-access-control
RUN chmod a+w /etc/subversion/* && chmod a+w /home/svn

# WebDav（httpでアクセスする）のために必要なモジュールをapacheのプロセスが参照できるようにコピーする
RUN cp /usr/lib/apache2/modules/mod_dav.so /usr/local/apache2/modules/ &&\
    cp /usr/lib/apache2/modules/mod_dav_svn.so /usr/local/apache2/modules/ &&\
    cp /usr/lib/apache2/modules/mod_authz_svn.so /usr/local/apache2/modules/

# svn.confをhttpd.confから読み込めるようにする
RUN echo 'Include conf/extra/svn.conf' >> /usr/local/apache2/conf/httpd.conf
COPY svn.conf /usr/local/apache2/conf/extra/

# SSL
RUN sed -i -e 's,#LoadModule socache_shmcb_module modules/mod_socache_shmcb.so,LoadModule socache_shmcb_module modules/mod_socache_shmcb.so,g' /usr/local/apache2/conf/httpd.conf
RUN sed -i -e 's,#LoadModule ssl_module modules/mod_ssl.so,LoadModule ssl_module modules/mod_ssl.so,g' /usr/local/apache2/conf/httpd.conf

# ssl.confをhttpd.confから読み込めるようにする
# RUN echo 'Include conf/extra/ssl.conf' >> /usr/local/apache2/conf/httpd.conf
# COPY ssl.conf /usr/local/apache2/conf/extra/
# COPY server.crt /usr/local/apache2/conf/
# COPY server.csr /usr/local/apache2/conf/
# COPY server.key /usr/local/apache2/conf/


# 実行ユーザーを作成するため、このDockerfile内で有効な環境変数を設定
ARG USERNAME=subversion
ARG GROUPNAME=subversion
ARG UID=999
ARG GID=999

# 実行ユーザーの作成
RUN groupadd -g $GID $GROUPNAME && \
    useradd -ml -s /bin/bash -u $UID -g $GID $USERNAME &&\
	echo "${USERNAME}:${USERNAME}" | sudo chpasswd

# 実行ユーザーでvi等で編集できるようにsudo権限をつけておく
RUN echo "Defaults visiblepw"             >> /etc/sudoers
RUN echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ディレクトリ権限の変更
RUN chown -R $UID:$GID /etc/services.d/apache &&\
	chown -R $UID:$GID /etc/services.d/subversion &&\
	chown -R $UID:$GID /etc/subversion &&\
	chown -R $UID:$GID /home/svn &&\
	chown -R $UID:$GID /usr/local/apache2

# 実行ユーザーの切り替え
USER $USERNAME

# http, https, svnのプロトコルでアクセスするためのポートをExpose
EXPOSE 80 443 3690