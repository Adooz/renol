from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login, logout
from django.contrib import messages

from userauths.models import User
from userauths.forms import UserRegisterForm

def RegisterView(request):
    if request.user.is_authenticated:
        messages.warning(request, f"You are already logged in.")
        return redirect("account:account")
    
    if request.method == "POST":
        form = UserRegisterForm(request.POST)
        if form.is_valid():
            # form.save()
            new_user = form.save() # new_user.email
            username = form.cleaned_data.get("username")
            # username = request.POST.get("username")
            messages.success(request, f"Hey {username}, your account was created successfully.")
            # new_user = authenticate(username=form.cleaned_data.get('email'))
            new_user = authenticate(username=form.cleaned_data['email'],
                                    password=form.cleaned_data['password1'])
            login(request, new_user)
            return redirect("account:account")

    else:
        form = UserRegisterForm()
    context = {
        "form": form
    }
    return render(request, "userauths/sign-up.html", context)


def LoginView(request):
    if request.method == "POST":
        # Accept either username or email as the identifier for compatibility
        identifier = request.POST.get("username") or request.POST.get("email")
        password = request.POST.get("password")

        # Try authenticate with username first (preferred), then with email
        user = authenticate(request, username=identifier, password=password)
        if user is None:
            # some backends use email as the USERNAME_FIELD; try passing email
            user = authenticate(request, email=identifier, password=password)

        if user is not None:
            login(request, user)
            messages.success(request, "You are logged.")
            return redirect("account:account")
        else:
            messages.warning(request, "Username/email or password does not exist")
            return redirect("userauths:sign-in")

    if request.user.is_authenticated:
        messages.warning(request, "You are already logged In")
        return redirect("account:account")
        
    return render(request, "userauths/sign-in.html")

def LogoutView(request):
    logout(request)
    messages.success(request, "You have been logged out.")
    return redirect("userauths:sign-in")