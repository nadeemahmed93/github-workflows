FROM  AS Build
COPY src /usr/src/app/src
COPY pom.xml /usr/src/app
COPY settings.xml /usr/src/app
RUN mvn -f /usr/src/app/pom.xml -s /usr/src/app/settings.xml clean package -DskipTests


# SonarQube Analysis
# ARG SONAR_SCANNER_URL
# ARG SONAR_TOKEN
# RUN mvn -f /usr/src/app/pom.xml -s /usr/src/app/settings.xml verify sonar:sonar \
#        -Dsonar.host.url="$SONAR_SCANNER_URL" \
#     -Dsonar.login="$SONAR_TOKEN"


FROM 
COPY --from=Build /usr/src/app/target/*.jar /usr/app/*.jar


USER root


ARG JAVA_KEYSTORE_PATH=lib/security/cacerts
COPY certs/ /usr/local/share/ca-certificates


RUN for f in /usr/local/share/ca-certificates/*; do \
    echo "Importing cert into java keystore: $f"; \
    keytool -importcert -keystore "${​​​​​​​JAVA_HOME}​​​​​​​/${​​​​​​​JAVA_KEYSTORE_PATH}​​​​​​​" -storepass changeit -noprompt -file "$f" -v -alias "$f"; \
    done


USER containeruser


EXPOSE 9090
ENTRYPOINT ["java", "-jar", "/usr/app/*.jar", "--server.address=0.0.0.0"]
 









