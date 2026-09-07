<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>이용약관 - AI 캡스톤디자인 관리시스템</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Noto Sans KR', sans-serif; }
        body { background-color: #f9f9f9; line-height: 1.6; color: #333; }
        .container { max-width: 800px; margin: 0 auto; padding: 20px; background: white; min-height: 100vh; }
        .header { text-align: center; padding: 30px 0; border-bottom: 2px solid #4751c9; margin-bottom: 30px; }
        .header h1 { color: #4751c9; font-size: 2rem; margin-bottom: 10px; }
        .header p { color: #666; font-size: 1rem; }
        .content { margin-bottom: 30px; }
        .section { margin-bottom: 30px; }
        .section h2 { color: #4751c9; font-size: 1.3rem; margin-bottom: 15px; border-left: 4px solid #4751c9; padding-left: 15px; }
        .section h3 { color: #333; font-size: 1.1rem; margin: 15px 0 10px 0; }
        .section p { margin-bottom: 12px; }
        .section ul { margin-left: 20px; margin-bottom: 15px; }
        .section li { margin-bottom: 8px; }
        .highlight { background-color: #fff3cd; padding: 10px; border-left: 4px solid #ffc107; margin: 15px 0; }
        .footer { text-align: center; padding: 20px; border-top: 1px solid #eee; color: #666; }
        .close-btn { display: inline-block; margin-top: 20px; background: #4751c9; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; }
        .close-btn:hover { background: #3640a8; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>이용약관</h1>
            <p>AI 캡스톤디자인 관리시스템 서비스 이용약관</p>
        </div>

        <div class="content">
            <div class="section">
                <h2>제1조 (목적)</h2>
                <p>이 약관은 AI 캡스톤디자인 관리시스템(이하 "시스템")이 제공하는 모든 서비스의 이용조건 및 절차, 이용자와 시스템 간의 권리, 의무, 책임사항과 기타 필요한 사항을 규정함을 목적으로 합니다.</p>
            </div>

            <div class="section">
                <h2>제2조 (정의)</h2>
                <p>이 약관에서 사용하는 용어의 정의는 다음과 같습니다:</p>
                <ul>
                    <li><strong>"시스템"</strong>이라 함은 AI 캡스톤디자인 관리시스템을 의미합니다.</li>
                    <li><strong>"이용자"</strong>라 함은 이 약관에 따라 시스템을 이용하는 학생, 교수, 교직원, 조교를 의미합니다.</li>
                    <li><strong>"서비스"</strong>라 함은 기자재 관리, 대여, 수리, 예약 및 채팅 기능 등 시스템이 제공하는 모든 기능을 의미합니다.</li>
                    <li><strong>"계정"</strong>이라 함은 서비스 이용을 위해 이용자가 등록한 개인정보를 의미합니다.</li>
                </ul>
            </div>

            <div class="section">
                <h2>제3조 (약관의 효력 및 변경)</h2>
                <p>1. 이 약관은 시스템에 게시하거나 기타의 방법으로 이용자에게 공지함으로써 효력을 발생합니다.</p>
                <p>2. 시스템은 약관의 규제에 관한 법률, 정보통신망이용촉진 및 정보보호 등에 관한 법률 등 관련법을 위배하지 않는 범위에서 이 약관을 개정할 수 있습니다.</p>
                <p>3. 약관이 개정되는 경우 시스템은 개정된 약관의 적용일자 및 개정사유를 명시하여 현행약관과 함께 공지합니다.</p>
            </div>

            <div class="section">
                <h2>제4조 (회원가입)</h2>
                <p>1. 이용자는 시스템이 정한 가입 양식에 따라 회원정보를 기입한 후 이 약관에 동의한다는 의사표시를 함으로써 회원가입을 신청합니다.</p>
                <p>2. 시스템은 제1항과 같이 회원으로 가입할 것을 신청한 이용자 중 다음 각 호에 해당하지 않는 한 회원으로 등록합니다:</p>
                <ul>
                    <li>가입신청자가 허위의 정보를 등록한 경우</li>
                    <li>기타 회원으로 등록하는 것이 시스템의 기술상 현저히 지장이 있다고 판단되는 경우</li>
                </ul>
            </div>

            <div class="section">
                <h2>제5조 (서비스의 제공 및 변경)</h2>
                <p>1. 시스템은 다음과 같은 업무를 수행합니다:</p>
                <ul>
                    <li>기자재 정보 관리 및 제공</li>
                    <li>기자재 대여, 수리, 예약 서비스</li>
                    <li>실시간 채팅 및 소통 서비스</li>
                    <li>문의 및 공지사항 서비스</li>
                    <li>기타 시스템이 정하는 업무</li>
                </ul>
                <p>2. 시스템은 운영상, 기술상의 필요에 따라 제공하고 있는 전부 또는 일부 서비스를 변경할 수 있습니다.</p>
            </div>

            <div class="section">
                <h2>제6조 (서비스의 중단)</h2>
                <p>1. 시스템은 컴퓨터 등 정보통신시설의 보수점검, 교체 및 고장, 통신의 두절 등의 사유가 발생한 경우에는 서비스의 제공을 일시적으로 중단할 수 있습니다.</p>
                <p>2. 시스템은 국가비상사태, 정전, 서비스 설비의 장애 또는 서비스 이용의 폭주 등으로 정상적인 서비스 이용에 지장이 있는 때에는 서비스의 전부 또는 일부를 제한하거나 정지할 수 있습니다.</p>
            </div>

            <div class="section">
                <h2>제7조 (회원의 의무)</h2>
                <p>1. 이용자는 다음 행위를 하여서는 안 됩니다:</p>
                <ul>
                    <li>신청 또는 변경 시 허위내용의 등록</li>
                    <li>타인의 정보 도용</li>
                    <li>시스템에 게시된 정보의 변경</li>
                    <li>시스템이 정한 정보 이외의 정보(컴퓨터 프로그램 등) 등의 송신 또는 게시</li>
                    <li>시스템 기타 제3자의 저작권 등 지적재산권에 대한 침해</li>
                    <li>시스템 기타 제3자의 명예를 손상시키거나 업무를 방해하는 행위</li>
                    <li>외설 또는 폭력적인 메시지, 화상, 음성, 기타 공서양속에 반하는 정보를 시스템에 공개 또는 게시하는 행위</li>
                </ul>
            </div>

            <div class="section">
                <h2>제8조 (기자재 이용 규칙)</h2>
                <div class="highlight">
                    <p><strong>중요:</strong> 기자재 대여 및 사용 시 다음 사항을 준수해야 합니다.</p>
                </div>
                <p>1. 기자재는 교육 및 연구 목적으로만 사용해야 합니다.</p>
                <p>2. 대여한 기자재는 지정된 기간 내에 반납해야 합니다.</p>
                <p>3. 기자재 분실, 훼손 시에는 즉시 관리자에게 신고해야 합니다.</p>
                <p>4. 타인과의 기자재 공유는 시스템을 통해서만 가능합니다.</p>
            </div>

            <div class="section">
                <h2>제9조 (개인정보보호)</h2>
                <p>시스템은 이용자의 개인정보 수집시 서비스제공을 위하여 필요한 범위에서 최소한의 개인정보를 수집합니다. 자세한 사항은 개인정보 처리방침을 참조하시기 바랍니다.</p>
            </div>

            <div class="section">
                <h2>제10조 (면책조항)</h2>
                <p>1. 시스템은 천재지변 또는 이에 준하는 불가항력으로 인하여 서비스를 제공할 수 없는 경우에는 서비스 제공에 관한 책임이 면제됩니다.</p>
                <p>2. 시스템은 이용자의 귀책사유로 인한 서비스 이용의 장애에 대하여는 책임을 지지 않습니다.</p>
                <p>3. 시스템은 이용자가 서비스를 이용하여 기대하는 손익이나 서비스를 통하여 얻은 자료로 인한 손해에 관하여 책임을 지지 않습니다.</p>
            </div>

            <div class="section">
                <h2>제11조 (준거법 및 재판관할)</h2>
                <p>1. 시스템과 이용자 간에 발생한 분쟁에 관한 소송은 대한민국 법률을 적용합니다.</p>
                <p>2. 시스템과 이용자 간에 발생한 분쟁에 관한 소송은 시스템 소재지를 관할하는 법원에서 제기합니다.</p>
            </div>
        </div>

        <div class="footer">
            <p><strong>시행일자:</strong> 2024년 1월 1일</p>
            <p><strong>AI 캡스톤디자인 관리시스템</strong></p>
            <a href="javascript:window.close();" class="close-btn">창 닫기</a>
        </div>
    </div>
</body>
</html> 