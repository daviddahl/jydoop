HBASE_PATH ?= /usr/lib/hbase
SPACE := $(NULL) $(NULL)
HBASE_CP = $(subst $(SPACE),:,$(wildcard $(HBASE_PATH)/*.jar) $(wildcard $(HBASE_PATH)/lib/*.jar))

#javac -classpath   HBaseDriver.java  -d out  -Xlint:deprecation  && jar -cvf taras.jar -C out/ . 
export HADOOP_USER_CLASSPATH_FIRST="true"
# this will need to change once more jars are added
export HADOOP_CLASSPATH=jython-standalone-2.7-b1.jar:akela-0.5-SNAPSHOT.jar:jyson-1.0.2.jar
CP=$(HADOOP_CLASSPATH):$(HBASE_CP)
comma:=,
JAVA_SOURCE=$(addprefix org/mozilla/pydoop/,PythonWrapper.java TypeWritable.java HBaseDriver.java)
TASK=HBaseDriver
ARGS=input output
SCRIPT=scripts/CallJava.py
all: driver.jar

run: driver.jar
	java -cp driver.jar:$(CP) org.mozilla.pydoop.$(TASK)

hadoop: driver.jar
#	-hadoop fs -rmr /user/tglek/output
	time hadoop jar $< org.mozilla.pydoop.$(TASK) -libjars $(subst :,$(comma),$(HADOOP_CLASSPATH)) $(ARGS)

driver.jar: out/CallJava.py $(JAVA_SOURCE)
	javac -Xlint:deprecation -d out  -cp $(CP) $(JAVA_SOURCE)
	jar -cvf $@ -C out .

out/CallJava.py: $(SCRIPT)
	mkdir -p out/script
	ln -vf $< $@

%.class: ../%.java

download:
	wget -c http://repo1.maven.org/maven2/org/python/jython-standalone/2.7-b1/jython-standalone-2.7-b1.jar -O jython-standalone-2.7-b1.jar
	wget -c http://people.mozilla.org/~bsmedberg/akela-0.5-SNAPSHOT.jar -O akela-0.5-SNAPSHOT.jar
	wget -c http://people.mozilla.org/~tglek/jyson-1.0.2.jar -O jyson-1.0.2.jar