<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>새 채팅방 만들기</title>
    <link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
</head>
<body>
    <div class="container">
        <div class="row justify-content-center mt-5">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h3 class="text-center">새 채팅방 만들기</h3>
                    </div>
                    <div class="card-body">
                        <form action="/chat/room/create" method="POST">
                            <div class="form-group">
                                <label for="roomName">채팅방 이름</label>
                                <input type="text" class="form-control" id="roomName" name="roomName" required>
                            </div>
                            <div class="form-group">
                                <label for="maxParticipants">최대 참여자 수</label>
                                <input type="number" class="form-control" id="maxParticipants" name="maxParticipants" min="2" max="10" value="10">
                            </div>
                            <div class="form-group">
                                <label for="description">설명</label>
                                <textarea class="form-control" id="description" name="description" rows="3"></textarea>
                            </div>
                            <div class="text-center">
                                <button type="submit" class="btn btn-primary">채팅방 만들기</button>
                                <a href="/chat/rooms" class="btn btn-secondary ml-2">취소</a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html> 