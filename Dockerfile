#
#  Copyright 2023 Netflix, Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
#  the License. You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
#  an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
#  specific language governing permissions and limitations under the License.
#


FROM openjdk:11-jdk AS builder
LABEL maintainer="Netflix OSS <conductor@netflix.com>"

COPY . /tmp/conductor

RUN \
    cd /tmp/conductor && \
    ./gradlew build -x test

FROM openjdk:11-jre
LABEL maintainer="Netflix OSS <conductor@netflix.com>"

WORKDIR /opt/conductor/
COPY --from=builder /tmp/conductor/server/build/libs/conductor-server-*-boot.jar /opt/conductor/conductor.jar

VOLUME [ "/opt/conductor/config.properties" ]
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 CMD [ "curl", "http://localhost:8080/health" ]

ENTRYPOINT [ "java", "-DCONDUCTOR_CONFIG_FILE=/app/config/config.properties", "-jar", "conductor.jar" ]
