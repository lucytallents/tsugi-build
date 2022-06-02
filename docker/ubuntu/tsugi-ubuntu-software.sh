
# http://jpetazzo.github.io/2013/10/06/policy-rc-d-do-not-start-services-automatically/
cat > /usr/sbin/policy-rc.d << EOF
#!/bin/sh
exit 0
EOF

env

# Cleanup is outside this file

