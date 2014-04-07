package Ninka::LicenseRules;

use strict;
use warnings;

our @GENERAL_NON_CRITICAL = ('AllRights');

our @GPL_NON_CRITICAL = (
    'GPLnoVersion',
    'FSFwarranty',
    'LibraryGPLcopyVer0',
    'GPLseeVer0',
    'GPLwrite',
    'SeeFile',
    'FreeSoftware',
    'FSFwarrantyVer0',
    'LibraryGPLseeDetailsVer0',
    'FSFwarranty',
    'LesserGPLseeDetailsVer0',
    'GPLcopyVer0',
    'GNUurl',
    'GPLseeDetailsVer0',
);

our %NON_CRITICAL_RULES = ();

$NON_CRITICAL_RULES{'LibraryGPLv3+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LibraryGPLv3'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LibraryGPLv2+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LibraryGPLv2'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LesserGPLv3'} = [@GPL_NON_CRITICAL, 'LesserGPLseeVer3', 'LesserGPLcopyVer3', 'SeeFileVer3'];
$NON_CRITICAL_RULES{'LesserGPLv2.1+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LesserGPLv2.1'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LGPLv2orv3'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LesserGPLv2'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LesserGPLv2+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'GPLVer2.1or3KDE+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'LGPLVer2.1or3KDE+'} = [@GPL_NON_CRITICAL];

$NON_CRITICAL_RULES{'GPLv2+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'GPLv2'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'GPLv1+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'GPLv1'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'GPLv3+'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'GPLv3'} = [@GPL_NON_CRITICAL];
$NON_CRITICAL_RULES{'AGPLv3'} = [@GPL_NON_CRITICAL, 'AGPLreceivedVer0', 'AGPLseeVer0'];
$NON_CRITICAL_RULES{'AGPLv3+'} = [@GPL_NON_CRITICAL, 'AGPLreceivedVer0', 'AGPLseeVer0'];
$NON_CRITICAL_RULES{'GPLnoVersion'} = [@GPL_NON_CRITICAL];

$NON_CRITICAL_RULES{'Apache-1.1'} = ['ApacheLic1_1'];
$NON_CRITICAL_RULES{'Apache-2'} = ['ApachePre', 'ApacheSee'];

$NON_CRITICAL_RULES{'LibGCJLic'} = ['LibGCJSee'];
$NON_CRITICAL_RULES{'CDDLicV1'} = ['Compliance', 'CDDLicWhere', 'ApachesPermLim', 'CDDLicIncludeFile', 'UseSubjectToTerm', 'useOnlyInCompliance'];
$NON_CRITICAL_RULES{'CDDLic'} = ['Compliance', 'CDDLicWhere', 'ApachesPermLim', 'CDDLicIncludeFile', 'UseSubjectToTerm', 'useOnlyInCompliance'];

$NON_CRITICAL_RULES{'CDDLorGPLv2'} = ['CDDLorGPLv2doNotAlter', 'AllRights', 'useOnlyInCompliance', 'CDDLorGPLv2whereVer0', 'ApachesPermLim', 'CDDLorGPLv2include', 'CDDLorGPLv2IfApplicable', 'CDDLorGPLv2Portions', 'CDDLorGPLv2ifYouWishVer2', 'CDDLorGPLv2IfYouAddVer2'];

$NON_CRITICAL_RULES{'CPLv1orGPLv2+orLGPLv2+'} = ['licenseBlockBegin', 'licenseBlockEnd'];

$NON_CRITICAL_RULES{'Qt'} = ['Copyright', 'qtNokiaExtra', 'QTNokiaContact', 'qtDiaTems'];
$NON_CRITICAL_RULES{'orLGPLVer2.1'} = ['LesserqtReviewGPLVer2.1', 'qtLGPLv2.1where'];
$NON_CRITICAL_RULES{'orGPLv3'} = ['qtReviewGPLVer3.0', 'qtReviewGPLVer3', 'qtGPLwhere'];
$NON_CRITICAL_RULES{'digiaQTExceptionNoticeVer1.1'} = ['qtDigiaExtra'];

$NON_CRITICAL_RULES{'MPLv1_0'} = ['ApacheLicWherePart1', 'MPLwarranty', 'MPLSee'];
$NON_CRITICAL_RULES{'MPLv1_1'} = ['ApacheLicWherePart1', 'MPLwarranty', 'MPLSee'];
$NON_CRITICAL_RULES{'NPLv1_1'} = ['ApacheLicWherePart1', 'MPLwarranty', 'MPLSee'];
$NON_CRITICAL_RULES{'NPLv1_0'} = ['ApacheLicWherePart1', 'MPLwarranty', 'MPLSee'];

$NON_CRITICAL_RULES{'subversion'} = ['SeeFileSVN', 'subversionHistory'];
$NON_CRITICAL_RULES{'subversion+'} = ['SeeFileSVN', 'subversionHistory'];
$NON_CRITICAL_RULES{'tmate+'} = ['SeeFileSVN'];

$NON_CRITICAL_RULES{'openSSLvar2'} = ['BSDcondAdvPart2'];

$NON_CRITICAL_RULES{'MPLv1_1'} = ['licenseBlockBegin', 'MPLsee', 'Copyright', 'licenseBlockEnd', 'ApacheLicWherePart1', 'MPLwarranty', 'MPLwarrantyVar'];
$NON_CRITICAL_RULES{'MPL1_1andLGPLv2_1'} = ['MPLoptionIfNotDelete2licsVer0', 'MPL_LGPLseeVer0'];

$NON_CRITICAL_RULES{'FreeType'} = ['FreeTypeNotice'];
$NON_CRITICAL_RULES{'boostV1'} = ['boostSeev1', 'SeeFile'];



1;

__END__

=head1 NAME

Ninka::LicenseRules

=head1 DESCRIPTION

Contains rules used by Ninka::LicenseMatcher.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009-2010  Yuki Manabe and Daniel M. German

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=cut
