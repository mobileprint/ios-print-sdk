rm -rf ../doc/*
headerdoc2html -o ../doc ../Pod/Classes/Public/*.h
gatherheaderdoc ../doc
cp index.php ../doc
cp toc.css ../doc