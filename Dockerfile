FROM alpine:latest
MAINTAINER Anders Rønning <anders.roenning@gmail.com>

RUN apk update && \
	apk upgrade && \
	apk add \
	coreutils \
	apk-cron \
	unzip \
	perl-libwww \
	perl-lwp-protocol-https \
	perl-datetime \
	busybox-suid \
	python \
	py-pip \
	&& pip install awscli \
	&& rm -rf /var/cache/apk/*

ENV HOME=/etc/cloudwatch

ADD container/ $HOME
ADD ./aws-scripts-mon $HOME/aws-scripts-mon/
RUN chmod -R +x $HOME

RUN crontab $HOME/crontab

CMD ["etc/cloudwatch/runapp.sh"]
