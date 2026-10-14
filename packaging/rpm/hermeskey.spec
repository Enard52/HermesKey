Name:           hermeskey
Version:        0.3.0
Release:        1%{?dist}
Summary:        Push-to-talk speech-to-text for Linux Wayland desktops
License:        MIT
URL:            https://github.com/graygarbage/HermesKey
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch

Requires:       bash
Requires:       ffmpeg
Requires:       wl-clipboard
Requires:       libnotify
Requires:       ydotool
Requires:       python3
Requires:       python3-pip
Requires:       python3-virtualenv
Requires:       pulseaudio-utils

%description
HermesKey is a local-first push-to-talk speech-to-text tool for Linux Wayland desktops.

%prep
%autosetup -n HermesKey

%build
# no build step required

%install
mkdir -p %{buildroot}%{_datadir}/hermeskey
mkdir -p %{buildroot}%{_datadir}/applications
mkdir -p %{buildroot}%{_datadir}/metainfo
cp -a * %{buildroot}%{_datadir}/hermeskey/
install -m 0644 desktop/hermeskey.metainfo.xml %{buildroot}%{_datadir}/metainfo/hermeskey.metainfo.xml
cp desktop/*.desktop.in %{buildroot}%{_datadir}/applications/

%files
%license LICENSE
%doc README.md CHANGELOG.md
%{_datadir}/hermeskey
%{_datadir}/applications
%{_datadir}/metainfo/hermeskey.metainfo.xml

%changelog
* Tue Oct 13 2026 Gray Garbage - 0.3.0-1
- Desktop integration and packaging scaffold refresh
