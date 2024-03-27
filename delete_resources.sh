docker image prune -af
docker container prune -f
docker volume rm $(docker volume ls -qf dangling=true)
docker builder prune -f

sudo rm -fR volume
mkdir volume
mkdir volume/subversion
mkdir volume/subversion/apache2_conf
mkdir volume/subversion/subversion_access
mkdir volume/subversion/svn_home
