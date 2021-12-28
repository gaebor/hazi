echo "# hazi
Automated Email Exercise Evaluator
"

echo -n "## MD5
This version's MD5 hash is:

    "
bash checksums.sh | cut -f1 -d' '
echo "
In detail:
"
bash checksums.sh -l | sed -e 's/^/    /'

echo "
Use \`checksums.sh\` to check MD5 hash.
"
echo "## In action:

* http://wiki.math.bme.hu/view/HazifeladatEllenorzoTeacher
* http://math.bme.hu/u/hazi"
