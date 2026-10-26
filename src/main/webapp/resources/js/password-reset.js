(() => {
    const token = new URLSearchParams(window.location.hash.slice(1)).get("token");
    if (token && /^[A-Za-z0-9_-]{43}$/.test(token)) {
        document.getElementById("reset-token").value = token;
    }
    if (window.location.hash) window.history.replaceState(null, "", window.location.pathname);
})();
