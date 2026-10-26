# 의존성 보안 패치 — 2026-10-26

기준 `9d2def4d872ba717b09b29edd1c0dcbc696df418`의 GitHub 알림 7개와 별도 Trivy POM 해석에서 확인한 경고 9개를 대조했다. 운영 DB·schema·Compose·권한·SMTP 설정은 변경하지 않는다.

| 실제 의존성 | 이전 | 보완 | 이유 |
|---|---|---|---|
| Log4j API/core/SLF4J 바인딩 | 2.20.0 | 2.25.5 | core의 2.25.4 수정 외에 API CVE-2026-49844의 수정도 포함 |
| MariaDB JDBC | 2.7.5 | 2.7.14 | 같은 2.7 계열의 보안 수정. DB 서버 버전이나 자료 변경 없음 |
| Okio JVM | 3.0.0(OkHttp 전이) | 3.4.0 | CVE-2023-3635 수정. 기존 OkHttp 4.10 호출은 유지 |
| MyBatis / 내부 OGNL | 3.5.13 / 3.3.4 | 3.6.0 / 3.4.16 | 실제 WAR 검사에서 발견한 shaded OGNL CVE-2026-113730. 외부 OGNL 의존성 추가로 내부 사본을 숨기지 않고 부모를 갱신 |

`mvn -B -ntp clean verify`는 로컬 JDK21에서 56개 중 55개 통과·1개 DB 전용 시험 skip, 실패/오류0과 ROOT.war 생성을 확인했다. DB 시험은 실제 MariaDB가 없는 로컬에서 건너뛰었으며, 기존 Linux CI의 합성 MariaDB·Tomcat 런타임 검증을 대체하지 않는다. 새 시험으로 버전 문자열만 고정하지 않고 기존 인증·세션·업로드 경계 회귀를 실행했다.

Trivy0.76.1의 기존 고정 DB로 POM 경고는 9→0이다. 첫 세 라이브러리 보완 후 실제 WAR 전개 rootfs에서 OGNL1건을 추가 발견해 MyBatis도 보완했고, 최종 POM52개·WAR54개 인식 패키지에서 모든 심각도 경고0을 확인했다. Maven resolved tree와 실제 WAR JAR도 대조했다. 값·업무 본문·과거 SMTP 키를 출력하거나 저장하지 않는다.

MyBatis3.6.0의 Java11 최소 요구는 이 앱의 Java17 컴파일·JDK21 실행 범위 안이다. [공식 릴리스](https://github.com/mybatis/mybatis-3/releases/tag/mybatis-3.6.0)와 [공식 Maven POM](https://repo.maven.apache.org/maven2/org/mybatis/mybatis/3.6.0/mybatis-3.6.0.pom)을 확인했다. SQL·mapper·schema는 바꾸지 않았고 실제 MariaDB mapper 회귀의 최종 결과는 기존 CI에서 확인해야 한다.

운영 적용 전에는 정확한 변경 SHA의 기존 CI·합성 MariaDB·Tomcat 검증과 배포 보호 경로 검토가 필요하다. 이 문서 작성 시 commit/push·운영 배포는 실행하지 않았다. 롤백은 이전 앱 이미지이며 DB 복원은 필요하지 않지만 구버전 라이브러리 위험이 다시 생긴다.
