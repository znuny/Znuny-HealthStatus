# --
# Kernel/Language/de_ZnunyHealthStatus.pm
# Copyright (C) 2012-2022 Znuny GmbH, http://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Language::de_ZnunyHealthStatus;

use strict;
use warnings;

use utf8;

sub Data {
    my $Self = shift;

    $Self->{Translation}->{'This configuration defines the API key a client has to provide for accessing the Znuny Health Status web service (min. 20 character).'} = 'Diese Konfiguration definiert den API-Schlüssel, den ein Client für den Zugriff auf den Znuny Health Status Webservice verwenden muss (min. 20 Zeichen).';

    return 1;
}

1;
