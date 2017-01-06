#!/bin/bash

username="$1"
password="$2"
email_addr="$3"

url_login="http://dtgssweb.dtc.cooper.edu/Student/Account/Login"
url="http://dtgssweb.dtc.cooper.edu/Student/Planning/Programs/GetStudentProgramEvaluations"

echo "$username: Change notifications will go to $email_addr"
if [ ! -f "grades/$username" ]
then
	touch grades/$username
fi

orig=$(md5sum "grades/$username")

# Get initial RequestVerificationToken
# By looking through the HTML, determined that the last occurence is the value we need
# Save the token as variable RVT and save cookies
RVT=$(
curl -c /tmp/cookies.$$ -s $url_login \
	| grep __RequestVerification \
	| tail -n1 \
	| sed "s/.* value=\"\(.*\)\".*/\1/"
)

# Login and get new RVT value
# From here on, RVT we want is the first occurence
# and I think we can use just the cookies instead
RVT=$(
curl -b /tmp/cookies.$$ -c /tmp/cookies.$$ -s -L -d "UserName=$username&Password=$password&__RequestVerificationToken=$RVT" $url_login \
	| grep __RequestVerification \
	| head -n1 \
	| sed "s/.* value=\"\(.*\)\".*/\1/"
)

while :
do
	echo "$username: Fetching grades..."

	# Get the entire 400K JSON
	# Cut out things before
	# and after {DegreePlan} node that we want
	# Use jq to print all the courses {Taken, Waivered} with corresponding grade and output as csv
	# Remove courses with no grades (Planned courses)
	# Replace comma string separator with a colon
	# Remove double quotes (beginning and end of line)
	curl -b /tmp/cookies.$$ -c /tmp/cookies.$$ -s --compressed $url \
		| sed -n 's/^.*\"DegreePlan\"/{\"DegreePlan\"/p' \
		| sed -n 's/,\"ActivePrograms\".*$/}/p' \
		| jq -r '.DegreePlan.Terms[] | . as $term | .PlannedCourses[] | [ $term.Code, .CourseTitleDisplay, .AcademicHistory.GradeDisplay ] | @csv' \
		| sed '/""/d' \
		| sed 's/","/: /g' \
		| sed 's/"//g' \
		| grep 2016FA > grades/$username

	printf "$username: Comparing checksums..."

	new=$(md5sum "grades/$username")
	if [ "$new" != "$orig" ]
       	then
		echo "Checksums are different!"
		printf "$username: Emailing a notification..."
		cat grades/$username |  mutt -s "[Mailbot] Grades have been updated!" $email_addr
		echo "Sent!"
		orig=$new
	else	
		echo "Checksums are equal."
	fi
	sleep 300

done

rm /tmp/cookies.$$

