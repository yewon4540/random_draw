from flask import Flask, render_template, request, redirect, url_for
import random

app = Flask(__name__)

# 사용자 목록과 배정 결과 저장
users = []
assigned = {}

@app.route("/", methods=["GET", "POST"])
def index():
    """
    메인 페이지: 사용자가 이름을 입력하여 등록
    """
    global users
    if request.method == "POST":
        name = request.form.get("name").strip()
        if not name:
            return "이름을 입력하세요!", 400
        if name in users:
            return f"{name}님은 이미 등록되었습니다!", 400

        users.append(name)
        return redirect(url_for("index"))
    return render_template("index.html", users=users)

@app.route("/draw", methods=["GET"])
def draw():
    """
    제비뽑기 실행: 특정 사용자의 결과 반환
    """
    global users, assigned

    # 선택된 사용자 이름 가져오기
    username = request.args.get("selected_user")
    if not username or username not in users:
        return "잘못된 요청입니다!", 400

    # 이미 결과가 생성된 경우 기존 결과 반환
    if assigned:
        user_result = assigned.get(username)
        if user_result:
            return render_template("result_user.html", username=username, result=user_result)

    if len(users) < 2:
        return "참여자가 최소 2명 이상이어야 합니다!", 400

    # 이름 섞기
    shuffled = users[:]
    random.shuffle(shuffled)

    # 본인 이름과 동일한 경우 다시 섞기
    while any(users[i] == shuffled[i] for i in range(len(users))):
        random.shuffle(shuffled)

    # 배정
    assigned = {users[i]: shuffled[i] for i in range(len(users))}

    # 선택된 사용자 결과 반환
    user_result = assigned.get(username)
    if not user_result:
        return "잘못된 요청입니다!", 400
    return render_template("result_user.html", username=username, result=user_result)

@app.route("/result/all", methods=["GET"])
def result_all():
    """
    전체 결과 보기
    """
    global assigned
    return render_template("result_all.html", assigned=assigned)

@app.route("/reset", methods=["GET"])
def reset():
    """
    사용자 목록 및 배정 결과 초기화
    """
    global users, assigned
    users = []
    assigned = {}
    return redirect(url_for("index"))

@app.route("/users", methods=["GET"])
def get_users():
    """
    참여자 목록 반환 (AJAX 요청 처리)
    """
    global users
    return {"users": users}


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5180)

