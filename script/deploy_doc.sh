./generate_doc.sh
cd ../doc
git add .
git commit -m "doc rev"
git push heroku master
cd ../script