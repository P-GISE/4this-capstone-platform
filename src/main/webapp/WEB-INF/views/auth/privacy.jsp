<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>개인정보 처리방침 - AI 캡스톤디자인 관리시스템</title>
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
        .table-responsive { overflow-x: auto; margin: 15px 0; }
        .table { width: 100%; border-collapse: collapse; }
        .table th, .table td { border: 1px solid #ddd; padding: 10px; text-align: left; }
        .table th { background-color: #f8f9fa; font-weight: bold; }
        .highlight { background-color: #e7f3ff; padding: 15px; border-left: 4px solid #007bff; margin: 15px 0; }
        .warning { background-color: #fff3cd; padding: 15px; border-left: 4px solid #ffc107; margin: 15px 0; }
        .footer { text-align: center; padding: 20px; border-top: 1px solid #eee; color: #666; }
        .close-btn { display: inline-block; margin-top: 20px; background: #4751c9; color: white; padding: 12px 30px; text-decoration: none; border-radius: 5px; }
        .close-btn:hover { background: #3640a8; }
        .contact-info { background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 15px 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>개인정보 처리방침</h1>
            <p>AI 캡스톤디자인 관리시스템 개인정보 처리방침</p>
        </div>

        <div class="content">
            <div class="section">
                <h2>제1조 (개인정보의 처리목적)</h2>
                <p>AI 캡스톤디자인 관리시스템(이하 "시스템")은 다음의 목적을 위하여 개인정보를 처리합니다. 처리하고 있는 개인정보는 다음의 목적 이외의 용도로는 이용되지 않으며, 이용 목적이 변경되는 경우에는 개인정보보호법 제18조에 따라 별도의 동의를 받는 등 필요한 조치를 이행할 예정입니다.</p>
                
                <h3>1. 회원 가입 및 관리</h3>
                <ul>
                    <li>회원 가입 의사 확인</li>
                    <li>회원제 서비스 제공에 따른 본인 식별·인증</li>
                    <li>회원자격 유지·관리</li>
                    <li>서비스 부정이용 방지</li>
                </ul>

                <h3>2. 기자재 관리 서비스 제공</h3>
                <ul>
                    <li>기자재 대여, 수리, 예약 서비스 제공</li>
                    <li>기자재 사용 현황 관리</li>
                    <li>서비스 이용내역 통지</li>
                </ul>

                <h3>3. 소통 및 상담</h3>
                <ul>
                    <li>문의사항 처리 및 답변</li>
                    <li>채팅 서비스 제공</li>
                    <li>공지사항 전달</li>
                </ul>
            </div>

            <div class="section">
                <h2>제2조 (개인정보의 처리 및 보유기간)</h2>
                <div class="highlight">
                    <p><strong>중요:</strong> 시스템은 법령에 따른 개인정보 보유·이용기간 또는 정보주체로부터 개인정보를 수집 시에 동의받은 개인정보 보유·이용기간 내에서 개인정보를 처리·보유합니다.</p>
                </div>

                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>처리 목적</th>
                                <th>보유기간</th>
                                <th>근거</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>회원 가입 및 관리</td>
                                <td>탈퇴 시까지</td>
                                <td>회원 서비스 제공을 위한 필수</td>
                            </tr>
                            <tr>
                                <td>기자재 대여 기록</td>
                                <td>3년</td>
                                <td>기자재 관리 및 분쟁 해결</td>
                            </tr>
                            <tr>
                                <td>문의 및 상담 기록</td>
                                <td>1년</td>
                                <td>서비스 개선 및 민원 처리</td>
                            </tr>
                            <tr>
                                <td>로그인 기록</td>
                                <td>6개월</td>
                                <td>시스템 보안 및 부정 사용 방지</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="section">
                <h2>제3조 (개인정보의 처리 항목)</h2>
                <p>시스템은 다음의 개인정보 항목을 처리하고 있습니다.</p>

                <h3>1. 필수항목</h3>
                <ul>
                    <li><strong>학생:</strong> 이름, 학번, 이메일, 휴대폰번호, 소속 학과, 학년, 입학년도</li>
                    <li><strong>교수:</strong> 이름, 교번, 이메일, 휴대폰번호, 소속 학과, 직급</li>
                    <li><strong>교직원:</strong> 이름, 교번, 이메일, 휴대폰번호, 소속 부서, 직급</li>
                    <li><strong>조교:</strong> 이름, 교번, 이메일, 휴대폰번호, 연구실명, 전공 분야</li>
                </ul>

                <h3>2. 자동 수집 항목</h3>
                <ul>
                    <li>IP주소, 쿠키, MAC주소, 서비스 이용기록</li>
                    <li>접속 로그, 접속 국가 정보</li>
                </ul>
            </div>

            <div class="section">
                <h2>제4조 (개인정보의 제3자 제공)</h2>
                <div class="warning">
                    <p><strong>알림:</strong> 시스템은 개인정보를 제1조(개인정보의 처리목적)에서 명시한 범위 내에서만 처리하며, 정보주체의 동의, 법률의 특별한 규정 등 개인정보보호법 제17조에 해당하는 경우에만 개인정보를 제3자에게 제공합니다.</p>
                </div>
                <p>현재 시스템은 개인정보를 제3자에게 제공하지 않습니다.</p>
            </div>

            <div class="section">
                <h2>제5조 (개인정보 보호책임자)</h2>
                <p>시스템은 개인정보 처리에 관한 업무를 총괄해서 책임지고, 개인정보 처리와 관련한 정보주체의 불만처리 및 피해구제 등을 위하여 아래와 같이 개인정보 보호책임자를 지정하고 있습니다.</p>
                
                <div class="contact-info">
                    <h3>▶ 개인정보 보호책임자</h3>
                    <ul>
                        <li><strong>성명:</strong> AI 캡스톤디자인 관리팀</li>
                        <li><strong>직책:</strong> 시스템 관리자</li>
                        <li><strong>연락처:</strong> admin@ibetter.kr</li>
                    </ul>
                    
                    <h3>▶ 개인정보 보호 담당부서</h3>
                    <ul>
                        <li><strong>부서명:</strong> 시스템 관리팀</li>
                        <li><strong>연락처:</strong> support@ibetter.kr</li>
                    </ul>
                </div>
            </div>

            <div class="section">
                <h2>제6조 (개인정보 처리방침 변경)</h2>
                <div class="highlight">
                    <p><strong>중요:</strong> 이 개인정보처리방침은 시행일로부터 적용되며, 법령 및 방침에 따른 변경내용의 추가, 삭제 및 정정이 있는 경우에는 변경사항의 시행 7일 전부터 공지사항을 통하여 고지할 것입니다.</p>
                </div>
            </div>
        </div>

        <div class="footer">
            <p><strong>개인정보 처리방침 시행일자:</strong> 2024년 1월 1일</p>
            <p><strong>AI 캡스톤디자인 관리시스템</strong></p>
            <a href="javascript:window.close();" class="close-btn">창 닫기</a>
        </div>
    </div>
</body>
</html> 