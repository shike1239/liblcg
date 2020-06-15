#!/bin/sh

# Display usage
cpack_usage()
{
  cat <<EOF
Usage: $0 [options]
Options: [defaults in brackets after descriptions]
  --help            print this message
  --version         print cmake installer version
  --prefix=dir      directory in which to install
  --include-subdir  include the LIBLCG-1.0.0-Darwin subdirectory
  --exclude-subdir  exclude the LIBLCG-1.0.0-Darwin subdirectory
  --skip-license    accept license
EOF
  exit 1
}

cpack_echo_exit()
{
  echo $1
  exit 1
}

# Display version
cpack_version()
{
  echo "LIBLCG Installer Version: 1.0.0, Copyright (c) Humanity"
}

# Helper function to fix windows paths.
cpack_fix_slashes ()
{
  echo "$1" | sed 's/\\/\//g'
}

interactive=TRUE
cpack_skip_license=FALSE
cpack_include_subdir=""
for a in "$@"; do
  if echo $a | grep "^--prefix=" > /dev/null 2> /dev/null; then
    cpack_prefix_dir=`echo $a | sed "s/^--prefix=//"`
    cpack_prefix_dir=`cpack_fix_slashes "${cpack_prefix_dir}"`
  fi
  if echo $a | grep "^--help" > /dev/null 2> /dev/null; then
    cpack_usage 
  fi
  if echo $a | grep "^--version" > /dev/null 2> /dev/null; then
    cpack_version 
    exit 2
  fi
  if echo $a | grep "^--include-subdir" > /dev/null 2> /dev/null; then
    cpack_include_subdir=TRUE
  fi
  if echo $a | grep "^--exclude-subdir" > /dev/null 2> /dev/null; then
    cpack_include_subdir=FALSE
  fi
  if echo $a | grep "^--skip-license" > /dev/null 2> /dev/null; then
    cpack_skip_license=TRUE
  fi
done

if [ "x${cpack_include_subdir}x" != "xx" -o "x${cpack_skip_license}x" = "xTRUEx" ]
then
  interactive=FALSE
fi

cpack_version
echo "This is a self-extracting archive."
toplevel="`pwd`"
if [ "x${cpack_prefix_dir}x" != "xx" ]
then
  toplevel="${cpack_prefix_dir}"
fi

echo "The archive will be extracted to: ${toplevel}"

if [ "x${interactive}x" = "xTRUEx" ]
then
  echo ""
  echo "If you want to stop extracting, please press <ctrl-C>."

  if [ "x${cpack_skip_license}x" != "xTRUEx" ]
  then
    more << '____cpack__here_doc____'
GNU GENERAL PUBLIC LICENSE
                       Version 3, 29 June 2007

 Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
 Everyone is permitted to copy and distribute verbatim copies
 of this license document, but changing it is not allowed.

                            Preamble

  The GNU General Public License is a free, copyleft license for
software and other kinds of works.

  The licenses for most software and other practical works are designed
to take away your freedom to share and change the works.  By contrast,
the GNU General Public License is intended to guarantee your freedom to
share and change all versions of a program--to make sure it remains free
software for all its users.  We, the Free Software Foundation, use the
GNU General Public License for most of our software; it applies also to
any other work released this way by its authors.  You can apply it to
your programs, too.

  When we speak of free software, we are referring to freedom, not
price.  Our General Public Licenses are designed to make sure that you
have the freedom to distribute copies of free software (and charge for
them if you wish), that you receive source code or can get it if you
want it, that you can change the software or use pieces of it in new
free programs, and that you know you can do these things.

  To protect your rights, we need to prevent others from denying you
these rights or asking you to surrender the rights.  Therefore, you have
certain responsibilities if you distribute copies of the software, or if
you modify it: responsibilities to respect the freedom of others.

  For example, if you distribute copies of such a program, whether
gratis or for a fee, you must pass on to the recipients the same
freedoms that you received.  You must make sure that they, too, receive
or can get the source code.  And you must show them these terms so they
know their rights.

  Developers that use the GNU GPL protect your rights with two steps:
(1) assert copyright on the software, and (2) offer you this License
giving you legal permission to copy, distribute and/or modify it.

  For the developers' and authors' protection, the GPL clearly explains
that there is no warranty for this free software.  For both users' and
authors' sake, the GPL requires that modified versions be marked as
changed, so that their problems will not be attributed erroneously to
authors of previous versions.

  Some devices are designed to deny users access to install or run
modified versions of the software inside them, although the manufacturer
can do so.  This is fundamentally incompatible with the aim of
protecting users' freedom to change the software.  The systematic
pattern of such abuse occurs in the area of products for individuals to
use, which is precisely where it is most unacceptable.  Therefore, we
have designed this version of the GPL to prohibit the practice for those
products.  If such problems arise substantially in other domains, we
stand ready to extend this provision to those domains in future versions
of the GPL, as needed to protect the freedom of users.

  Finally, every program is threatened constantly by software patents.
States should not allow patents to restrict development and use of
software on general-purpose computers, but in those that do, we wish to
avoid the special danger that patents applied to a free program could
make it effectively proprietary.  To prevent this, the GPL assures that
patents cannot be used to render the program non-free.

  The precise terms and conditions for copying, distribution and
modification follow.

                       TERMS AND CONDITIONS

  0. Definitions.

  "This License" refers to version 3 of the GNU General Public License.

  "Copyright" also means copyright-like laws that apply to other kinds of
works, such as semiconductor masks.

  "The Program" refers to any copyrightable work licensed under this
License.  Each licensee is addressed as "you".  "Licensees" and
"recipients" may be individuals or organizations.

  To "modify" a work means to copy from or adapt all or part of the work
in a fashion requiring copyright permission, other than the making of an
exact copy.  The resulting work is called a "modified version" of the
earlier work or a work "based on" the earlier work.

  A "covered work" means either the unmodified Program or a work based
on the Program.

  To "propagate" a work means to do anything with it that, without
permission, would make you directly or secondarily liable for
infringement under applicable copyright law, except executing it on a
computer or modifying a private copy.  Propagation includes copying,
distribution (with or without modification), making available to the
public, and in some countries other activities as well.

  To "convey" a work means any kind of propagation that enables other
parties to make or receive copies.  Mere interaction with a user through
a computer network, with no transfer of a copy, is not conveying.

  An interactive user interface displays "Appropriate Legal Notices"
to the extent that it includes a convenient and prominently visible
feature that (1) displays an appropriate copyright notice, and (2)
tells the user that there is no warranty for the work (except to the
extent that warranties are provided), that licensees may convey the
work under this License, and how to view a copy of this License.  If
the interface presents a list of user commands or options, such as a
menu, a prominent item in the list meets this criterion.

  1. Source Code.

  The "source code" for a work means the preferred form of the work
for making modifications to it.  "Object code" means any non-source
form of a work.

  A "Standard Interface" means an interface that either is an official
standard defined by a recognized standards body, or, in the case of
interfaces specified for a particular programming language, one that
is widely used among developers working in that language.

  The "System Libraries" of an executable work include anything, other
than the work as a whole, that (a) is included in the normal form of
packaging a Major Component, but which is not part of that Major
Component, and (b) serves only to enable use of the work with that
Major Component, or to implement a Standard Interface for which an
implementation is available to the public in source code form.  A
"Major Component", in this context, means a major essential component
(kernel, window system, and so on) of the specific operating system
(if any) on which the executable work runs, or a compiler used to
produce the work, or an object code interpreter used to run it.

  The "Corresponding Source" for a work in object code form means all
the source code needed to generate, install, and (for an executable
work) run the object code and to modify the work, including scripts to
control those activities.  However, it does not include the work's
System Libraries, or general-purpose tools or generally available free
programs which are used unmodified in performing those activities but
which are not part of the work.  For example, Corresponding Source
includes interface definition files associated with source files for
the work, and the source code for shared libraries and dynamically
linked subprograms that the work is specifically designed to require,
such as by intimate data communication or control flow between those
subprograms and other parts of the work.

  The Corresponding Source need not include anything that users
can regenerate automatically from other parts of the Corresponding
Source.

  The Corresponding Source for a work in source code form is that
same work.

  2. Basic Permissions.

  All rights granted under this License are granted for the term of
copyright on the Program, and are irrevocable provided the stated
conditions are met.  This License explicitly affirms your unlimited
permission to run the unmodified Program.  The output from running a
covered work is covered by this License only if the output, given its
content, constitutes a covered work.  This License acknowledges your
rights of fair use or other equivalent, as provided by copyright law.

  You may make, run and propagate covered works that you do not
convey, without conditions so long as your license otherwise remains
in force.  You may convey covered works to others for the sole purpose
of having them make modifications exclusively for you, or provide you
with facilities for running those works, provided that you comply with
the terms of this License in conveying all material for which you do
not control copyright.  Those thus making or running the covered works
for you must do so exclusively on your behalf, under your direction
and control, on terms that prohibit them from making any copies of
your copyrighted material outside their relationship with you.

  Conveying under any other circumstances is permitted solely under
the conditions stated below.  Sublicensing is not allowed; section 10
makes it unnecessary.

  3. Protecting Users' Legal Rights From Anti-Circumvention Law.

  No covered work shall be deemed part of an effective technological
measure under any applicable law fulfilling obligations under article
11 of the WIPO copyright treaty adopted on 20 December 1996, or
similar laws prohibiting or restricting circumvention of such
measures.

  When you convey a covered work, you waive any legal power to forbid
circumvention of technological measures to the extent such circumvention
is effected by exercising rights under this License with respect to
the covered work, and you disclaim any intention to limit operation or
modification of the work as a means of enforcing, against the work's
users, your or third parties' legal rights to forbid circumvention of
technological measures.

  4. Conveying Verbatim Copies.

  You may convey verbatim copies of the Program's source code as you
receive it, in any medium, provided that you conspicuously and
appropriately publish on each copy an appropriate copyright notice;
keep intact all notices stating that this License and any
non-permissive terms added in accord with section 7 apply to the code;
keep intact all notices of the absence of any warranty; and give all
recipients a copy of this License along with the Program.

  You may charge any price or no price for each copy that you convey,
and you may offer support or warranty protection for a fee.

  5. Conveying Modified Source Versions.

  You may convey a work based on the Program, or the modifications to
produce it from the Program, in the form of source code under the
terms of section 4, provided that you also meet all of these conditions:

    a) The work must carry prominent notices stating that you modified
    it, and giving a relevant date.

    b) The work must carry prominent notices stating that it is
    released under this License and any conditions added under section
    7.  This requirement modifies the requirement in section 4 to
    "keep intact all notices".

    c) You must license the entire work, as a whole, under this
    License to anyone who comes into possession of a copy.  This
    License will therefore apply, along with any applicable section 7
    additional terms, to the whole of the work, and all its parts,
    regardless of how they are packaged.  This License gives no
    permission to license the work in any other way, but it does not
    invalidate such permission if you have separately received it.

    d) If the work has interactive user interfaces, each must display
    Appropriate Legal Notices; however, if the Program has interactive
    interfaces that do not display Appropriate Legal Notices, your
    work need not make them do so.

  A compilation of a covered work with other separate and independent
works, which are not by their nature extensions of the covered work,
and which are not combined with it such as to form a larger program,
in or on a volume of a storage or distribution medium, is called an
"aggregate" if the compilation and its resulting copyright are not
used to limit the access or legal rights of the compilation's users
beyond what the individual works permit.  Inclusion of a covered work
in an aggregate does not cause this License to apply to the other
parts of the aggregate.

  6. Conveying Non-Source Forms.

  You may convey a covered work in object code form under the terms
of sections 4 and 5, provided that you also convey the
machine-readable Corresponding Source under the terms of this License,
in one of these ways:

    a) Convey the object code in, or embodied in, a physical product
    (including a physical distribution medium), accompanied by the
    Corresponding Source fixed on a durable physical medium
    customarily used for software interchange.

    b) Convey the object code in, or embodied in, a physical product
    (including a physical distribution medium), accompanied by a
    written offer, valid for at least three years and valid for as
    long as you offer spare parts or customer support for that product
    model, to give anyone who possesses the object code either (1) a
    copy of the Corresponding Source for all the software in the
    product that is covered by this License, on a durable physical
    medium customarily used for software interchange, for a price no
    more than your reasonable cost of physically performing this
    conveying of source, or (2) access to copy the
    Corresponding Source from a network server at no charge.

    c) Convey individual copies of the object code with a copy of the
    written offer to provide the Corresponding Source.  This
    alternative is allowed only occasionally and noncommercially, and
    only if you received the object code with such an offer, in accord
    with subsection 6b.

    d) Convey the object code by offering access from a designated
    place (gratis or for a charge), and offer equivalent access to the
    Corresponding Source in the same way through the same place at no
    further charge.  You need not require recipients to copy the
    Corresponding Source along with the object code.  If the place to
    copy the object code is a network server, the Corresponding Source
    may be on a different server (operated by you or a third party)
    that supports equivalent copying facilities, provided you maintain
    clear directions next to the object code saying where to find the
    Corresponding Source.  Regardless of what server hosts the
    Corresponding Source, you remain obligated to ensure that it is
    available for as long as needed to satisfy these requirements.

    e) Convey the object code using peer-to-peer transmission, provided
    you inform other peers where the object code and Corresponding
    Source of the work are being offered to the general public at no
    charge under subsection 6d.

  A separable portion of the object code, whose source code is excluded
from the Corresponding Source as a System Library, need not be
included in conveying the object code work.

  A "User Product" is either (1) a "consumer product", which means any
tangible personal property which is normally used for personal, family,
or household purposes, or (2) anything designed or sold for incorporation
into a dwelling.  In determining whether a product is a consumer product,
doubtful cases shall be resolved in favor of coverage.  For a particular
product received by a particular user, "normally used" refers to a
typical or common use of that class of product, regardless of the status
of the particular user or of the way in which the particular user
actually uses, or expects or is expected to use, the product.  A product
is a consumer product regardless of whether the product has substantial
commercial, industrial or non-consumer uses, unless such uses represent
the only significant mode of use of the product.

  "Installation Information" for a User Product means any methods,
procedures, authorization keys, or other information required to install
and execute modified versions of a covered work in that User Product from
a modified version of its Corresponding Source.  The information must
suffice to ensure that the continued functioning of the modified object
code is in no case prevented or interfered with solely because
modification has been made.

  If you convey an object code work under this section in, or with, or
specifically for use in, a User Product, and the conveying occurs as
part of a transaction in which the right of possession and use of the
User Product is transferred to the recipient in perpetuity or for a
fixed term (regardless of how the transaction is characterized), the
Corresponding Source conveyed under this section must be accompanied
by the Installation Information.  But this requirement does not apply
if neither you nor any third party retains the ability to install
modified object code on the User Product (for example, the work has
been installed in ROM).

  The requirement to provide Installation Information does not include a
requirement to continue to provide support service, warranty, or updates
for a work that has been modified or installed by the recipient, or for
the User Product in which it has been modified or installed.  Access to a
network may be denied when the modification itself materially and
adversely affects the operation of the network or violates the rules and
protocols for communication across the network.

  Corresponding Source conveyed, and Installation Information provided,
in accord with this section must be in a format that is publicly
documented (and with an implementation available to the public in
source code form), and must require no special password or key for
unpacking, reading or copying.

  7. Additional Terms.

  "Additional permissions" are terms that supplement the terms of this
License by making exceptions from one or more of its conditions.
Additional permissions that are applicable to the entire Program shall
be treated as though they were included in this License, to the extent
that they are valid under applicable law.  If additional permissions
apply only to part of the Program, that part may be used separately
under those permissions, but the entire Program remains governed by
this License without regard to the additional permissions.

  When you convey a copy of a covered work, you may at your option
remove any additional permissions from that copy, or from any part of
it.  (Additional permissions may be written to require their own
removal in certain cases when you modify the work.)  You may place
additional permissions on material, added by you to a covered work,
for which you have or can give appropriate copyright permission.

  Notwithstanding any other provision of this License, for material you
add to a covered work, you may (if authorized by the copyright holders of
that material) supplement the terms of this License with terms:

    a) Disclaiming warranty or limiting liability differently from the
    terms of sections 15 and 16 of this License; or

    b) Requiring preservation of specified reasonable legal notices or
    author attributions in that material or in the Appropriate Legal
    Notices displayed by works containing it; or

    c) Prohibiting misrepresentation of the origin of that material, or
    requiring that modified versions of such material be marked in
    reasonable ways as different from the original version; or

    d) Limiting the use for publicity purposes of names of licensors or
    authors of the material; or

    e) Declining to grant rights under trademark law for use of some
    trade names, trademarks, or service marks; or

    f) Requiring indemnification of licensors and authors of that
    material by anyone who conveys the material (or modified versions of
    it) with contractual assumptions of liability to the recipient, for
    any liability that these contractual assumptions directly impose on
    those licensors and authors.

  All other non-permissive additional terms are considered "further
restrictions" within the meaning of section 10.  If the Program as you
received it, or any part of it, contains a notice stating that it is
governed by this License along with a term that is a further
restriction, you may remove that term.  If a license document contains
a further restriction but permits relicensing or conveying under this
License, you may add to a covered work material governed by the terms
of that license document, provided that the further restriction does
not survive such relicensing or conveying.

  If you add terms to a covered work in accord with this section, you
must place, in the relevant source files, a statement of the
additional terms that apply to those files, or a notice indicating
where to find the applicable terms.

  Additional terms, permissive or non-permissive, may be stated in the
form of a separately written license, or stated as exceptions;
the above requirements apply either way.

  8. Termination.

  You may not propagate or modify a covered work except as expressly
provided under this License.  Any attempt otherwise to propagate or
modify it is void, and will automatically terminate your rights under
this License (including any patent licenses granted under the third
paragraph of section 11).

  However, if you cease all violation of this License, then your
license from a particular copyright holder is reinstated (a)
provisionally, unless and until the copyright holder explicitly and
finally terminates your license, and (b) permanently, if the copyright
holder fails to notify you of the violation by some reasonable means
prior to 60 days after the cessation.

  Moreover, your license from a particular copyright holder is
reinstated permanently if the copyright holder notifies you of the
violation by some reasonable means, this is the first time you have
received notice of violation of this License (for any work) from that
copyright holder, and you cure the violation prior to 30 days after
your receipt of the notice.

  Termination of your rights under this section does not terminate the
licenses of parties who have received copies or rights from you under
this License.  If your rights have been terminated and not permanently
reinstated, you do not qualify to receive new licenses for the same
material under section 10.

  9. Acceptance Not Required for Having Copies.

  You are not required to accept this License in order to receive or
run a copy of the Program.  Ancillary propagation of a covered work
occurring solely as a consequence of using peer-to-peer transmission
to receive a copy likewise does not require acceptance.  However,
nothing other than this License grants you permission to propagate or
modify any covered work.  These actions infringe copyright if you do
not accept this License.  Therefore, by modifying or propagating a
covered work, you indicate your acceptance of this License to do so.

  10. Automatic Licensing of Downstream Recipients.

  Each time you convey a covered work, the recipient automatically
receives a license from the original licensors, to run, modify and
propagate that work, subject to this License.  You are not responsible
for enforcing compliance by third parties with this License.

  An "entity transaction" is a transaction transferring control of an
organization, or substantially all assets of one, or subdividing an
organization, or merging organizations.  If propagation of a covered
work results from an entity transaction, each party to that
transaction who receives a copy of the work also receives whatever
licenses to the work the party's predecessor in interest had or could
give under the previous paragraph, plus a right to possession of the
Corresponding Source of the work from the predecessor in interest, if
the predecessor has it or can get it with reasonable efforts.

  You may not impose any further restrictions on the exercise of the
rights granted or affirmed under this License.  For example, you may
not impose a license fee, royalty, or other charge for exercise of
rights granted under this License, and you may not initiate litigation
(including a cross-claim or counterclaim in a lawsuit) alleging that
any patent claim is infringed by making, using, selling, offering for
sale, or importing the Program or any portion of it.

  11. Patents.

  A "contributor" is a copyright holder who authorizes use under this
License of the Program or a work on which the Program is based.  The
work thus licensed is called the contributor's "contributor version".

  A contributor's "essential patent claims" are all patent claims
owned or controlled by the contributor, whether already acquired or
hereafter acquired, that would be infringed by some manner, permitted
by this License, of making, using, or selling its contributor version,
but do not include claims that would be infringed only as a
consequence of further modification of the contributor version.  For
purposes of this definition, "control" includes the right to grant
patent sublicenses in a manner consistent with the requirements of
this License.

  Each contributor grants you a non-exclusive, worldwide, royalty-free
patent license under the contributor's essential patent claims, to
make, use, sell, offer for sale, import and otherwise run, modify and
propagate the contents of its contributor version.

  In the following three paragraphs, a "patent license" is any express
agreement or commitment, however denominated, not to enforce a patent
(such as an express permission to practice a patent or covenant not to
sue for patent infringement).  To "grant" such a patent license to a
party means to make such an agreement or commitment not to enforce a
patent against the party.

  If you convey a covered work, knowingly relying on a patent license,
and the Corresponding Source of the work is not available for anyone
to copy, free of charge and under the terms of this License, through a
publicly available network server or other readily accessible means,
then you must either (1) cause the Corresponding Source to be so
available, or (2) arrange to deprive yourself of the benefit of the
patent license for this particular work, or (3) arrange, in a manner
consistent with the requirements of this License, to extend the patent
license to downstream recipients.  "Knowingly relying" means you have
actual knowledge that, but for the patent license, your conveying the
covered work in a country, or your recipient's use of the covered work
in a country, would infringe one or more identifiable patents in that
country that you have reason to believe are valid.

  If, pursuant to or in connection with a single transaction or
arrangement, you convey, or propagate by procuring conveyance of, a
covered work, and grant a patent license to some of the parties
receiving the covered work authorizing them to use, propagate, modify
or convey a specific copy of the covered work, then the patent license
you grant is automatically extended to all recipients of the covered
work and works based on it.

  A patent license is "discriminatory" if it does not include within
the scope of its coverage, prohibits the exercise of, or is
conditioned on the non-exercise of one or more of the rights that are
specifically granted under this License.  You may not convey a covered
work if you are a party to an arrangement with a third party that is
in the business of distributing software, under which you make payment
to the third party based on the extent of your activity of conveying
the work, and under which the third party grants, to any of the
parties who would receive the covered work from you, a discriminatory
patent license (a) in connection with copies of the covered work
conveyed by you (or copies made from those copies), or (b) primarily
for and in connection with specific products or compilations that
contain the covered work, unless you entered into that arrangement,
or that patent license was granted, prior to 28 March 2007.

  Nothing in this License shall be construed as excluding or limiting
any implied license or other defenses to infringement that may
otherwise be available to you under applicable patent law.

  12. No Surrender of Others' Freedom.

  If conditions are imposed on you (whether by court order, agreement or
otherwise) that contradict the conditions of this License, they do not
excuse you from the conditions of this License.  If you cannot convey a
covered work so as to satisfy simultaneously your obligations under this
License and any other pertinent obligations, then as a consequence you may
not convey it at all.  For example, if you agree to terms that obligate you
to collect a royalty for further conveying from those to whom you convey
the Program, the only way you could satisfy both those terms and this
License would be to refrain entirely from conveying the Program.

  13. Use with the GNU Affero General Public License.

  Notwithstanding any other provision of this License, you have
permission to link or combine any covered work with a work licensed
under version 3 of the GNU Affero General Public License into a single
combined work, and to convey the resulting work.  The terms of this
License will continue to apply to the part which is the covered work,
but the special requirements of the GNU Affero General Public License,
section 13, concerning interaction through a network will apply to the
combination as such.

  14. Revised Versions of this License.

  The Free Software Foundation may publish revised and/or new versions of
the GNU General Public License from time to time.  Such new versions will
be similar in spirit to the present version, but may differ in detail to
address new problems or concerns.

  Each version is given a distinguishing version number.  If the
Program specifies that a certain numbered version of the GNU General
Public License "or any later version" applies to it, you have the
option of following the terms and conditions either of that numbered
version or of any later version published by the Free Software
Foundation.  If the Program does not specify a version number of the
GNU General Public License, you may choose any version ever published
by the Free Software Foundation.

  If the Program specifies that a proxy can decide which future
versions of the GNU General Public License can be used, that proxy's
public statement of acceptance of a version permanently authorizes you
to choose that version for the Program.

  Later license versions may give you additional or different
permissions.  However, no additional obligations are imposed on any
author or copyright holder as a result of your choosing to follow a
later version.

  15. Disclaimer of Warranty.

  THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY
APPLICABLE LAW.  EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT
HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY
OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM
IS WITH YOU.  SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF
ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

  16. Limitation of Liability.

  IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MODIFIES AND/OR CONVEYS
THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY
GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE
USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF
DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD
PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS),
EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

  17. Interpretation of Sections 15 and 16.

  If the disclaimer of warranty and limitation of liability provided
above cannot be given local legal effect according to their terms,
reviewing courts shall apply local law that most closely approximates
an absolute waiver of all civil liability in connection with the
Program, unless a warranty or assumption of liability accompanies a
copy of the Program in return for a fee.

                     END OF TERMS AND CONDITIONS

            How to Apply These Terms to Your New Programs

  If you develop a new program, and you want it to be of the greatest
possible use to the public, the best way to achieve this is to make it
free software which everyone can redistribute and change under these terms.

  To do so, attach the following notices to the program.  It is safest
to attach them to the start of each source file to most effectively
state the exclusion of warranty; and each file should have at least
the "copyright" line and a pointer to where the full notice is found.

    <one line to give the program's name and a brief idea of what it does.>
    Copyright (C) <year>  <name of author>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

Also add information on how to contact you by electronic and paper mail.

  If the program does terminal interaction, make it output a short
notice like this when it starts in an interactive mode:

    <program>  Copyright (C) <year>  <name of author>
    This program comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
    This is free software, and you are welcome to redistribute it
    under certain conditions; type `show c' for details.

The hypothetical commands `show w' and `show c' should show the appropriate
parts of the General Public License.  Of course, your program's commands
might be different; for a GUI interface, you would use an "about box".

  You should also get your employer (if you work as a programmer) or school,
if any, to sign a "copyright disclaimer" for the program, if necessary.
For more information on this, and how to apply and follow the GNU GPL, see
<https://www.gnu.org/licenses/>.

  The GNU General Public License does not permit incorporating your program
into proprietary programs.  If your program is a subroutine library, you
may consider it more useful to permit linking proprietary applications with
the library.  If this is what you want to do, use the GNU Lesser General
Public License instead of this License.  But first, please read
<https://www.gnu.org/licenses/why-not-lgpl.html>.

____cpack__here_doc____
    echo
    echo "Do you accept the license? [yN]: "
    read line leftover
    case ${line} in
      y* | Y*)
        cpack_license_accepted=TRUE;;
      *)
        echo "License not accepted. Exiting ..."
        exit 1;;
    esac
  fi

  if [ "x${cpack_include_subdir}x" = "xx" ]
  then
    echo "By default the LIBLCG will be installed in:"
    echo "  \"${toplevel}/LIBLCG-1.0.0-Darwin\""
    echo "Do you want to include the subdirectory LIBLCG-1.0.0-Darwin?"
    echo "Saying no will install in: \"${toplevel}\" [Yn]: "
    read line leftover
    cpack_include_subdir=TRUE
    case ${line} in
      n* | N*)
        cpack_include_subdir=FALSE
    esac
  fi
fi

if [ "x${cpack_include_subdir}x" = "xTRUEx" ]
then
  toplevel="${toplevel}/LIBLCG-1.0.0-Darwin"
  mkdir -p "${toplevel}"
fi
echo
echo "Using target directory: ${toplevel}"
echo "Extracting, please wait..."
echo ""

# take the archive portion of this file and pipe it to tar
# the NUMERIC parameter in this command should be one more
# than the number of lines in this header file
# there are tails which don't understand the "-n" argument, e.g. on SunOS
# OTOH there are tails which complain when not using the "-n" argument (e.g. GNU)
# so at first try to tail some file to see if tail fails if used with "-n"
# if so, don't use "-n"
use_new_tail_syntax="-n"
tail $use_new_tail_syntax +1 "$0" > /dev/null 2> /dev/null || use_new_tail_syntax=""

extractor="pax -r"
command -v pax > /dev/null 2> /dev/null || extractor="tar xf -"

tail $use_new_tail_syntax +821 "$0" | gunzip | (cd "${toplevel}" && ${extractor}) || cpack_echo_exit "Problem unpacking the LIBLCG-1.0.0-Darwin"

echo "Unpacking finished successfully"

exit 0
#-----------------------------------------------------------
#      Start of TAR.GZ file
#-----------------------------------------------------------;

� h��^ �}|[Ց������ic� N��؉�#؉���ND�@BMY�cYz$�lMS�ƋKٟ���5}�-ݺ����ek(K\0���]﷡�]
��^Z�B�͜9����d�@�[�V9wν3�93�+�;��'����a���WT��]G����Z~��k׭/�X����&�J׮-+ĊrR������=-���C~�����r�:��������/i��� }�+/7�����u�����ז���U�^m�|������fլ�5��X\%±��kŀ�)�C�p��#�'�t|�;��G�^�/+���es(|(����=+�2[���le�=~����oE4Z��Bqo�'ԺY���Fň/��y%�N_�8���菊-����������χ��#�}��XHt�a_$
�������n�w�ʃ�c- )j�tG|p�WtG�!���!O�V�����/*�Z|���ʕl��@��������A�%��Bb�Ŭ�q&�倿��AvZ=���(,'�Zly��������?ڲZ��QzS<�Q������Y��Q_�M��al���m8P���b���Pk�z�lV��H�16o��������h���F�������N��n
�e��C1�5Mw$��4�mq�a4���`p�a���N|8�b8a�jW,Y�N�]lؾe���;�bm��ܱ���{�xeu�W�o���ؾk�w�޶s��}�X�m�xK�բ}�s���Aܾ���;�j��]�msݮ��m[�M��m�N����v'�ݹ��ɥ��P^�}�f�՛j�jw�Y�����܆��l�!V���;k7磌�!:w�pno��$j@��m[v�@�z���%00��ۀ�uu8�]��8Qq�v��[;E���;tn����7��i4X������bMu}�V;����"�N��x�Î�8j5������p=��o۹�հ�;e��k������-;�׳��v�i;����$5��Apһ�L��^]�`��i77y�ǚŋ����^_��ۼ��X��!�I�b��"~���b���Dv+�x��!7xơ0:4]%"������i<}R i���d�k#N������.&��i섻�ŷ� ��7�ОP<�E߉�<��A�=�=9q$�"�+a� �Q4�/oU]w!���/�Q����|���f�"T�歫'���LA�Iƌ����ݠb���h�M��ޘ'�,��#1#1e�1�)�;�!n%;1%JQ>!�$�꽨w��[!��A�/Z-X�;��܁8�p��f+aD��Ӑ�+�Gd�>� ��Ґd�<ƛ��"T���ns������Q 5�r��gA��1�#S"L;iF^��<0�Fv{<��s�����ia�0�x�g0�&ġx�[B+�A �=\AL"h;
|A������9|���a�ƛD�#L�pu�x��)��Τ�jb5��<|�$z}�c|���'���!(ו����2�;�c2�7ו��v�F�n��u\�r�����{��r@b�5�L�f�4ld:��5+A���>T������h�8�p$wG������h�pZ�l�M�(�/��}8a�^�d��[v?J
�>��ӹ�ߍ�S;�$��OrϦP(��v�b՚�An���l��	��P��pK�>�}��%�AP��L��s� �f���#q<� )��ۋa v�-n[����6qE�
�f����"X$$O@n�V���P�����a��!z�0U�ùcn�l��C�J0ͳYn���Ҽ"R�k�Ib�Vq9��VkV֖�tE҈�π��y�L�5�&:(x5�X[��B~�X�
�nÕ�±��b�^%ksp8U�w�ضZM�j\�m�} i^+a���n�� w �R6{?�N�2c)b�KJ������L����b�j�Q2D��d�����X���|G ��')A#M��(-ʷ��Mf�K3aeH���G���0��d�;|���B����6��1S�X��Ç$O�mpC���A��~˒��Px�����v%-eh���>y{�WPu������k�q�S����"����UC�C��Y^!=��v}��T��Ԓ��;q��"L�8�P���[89�U�O!y��Ū����C��1�Q�Ҫ\?y~�J��h�45�����W��8&s"k��i��4)	�����bT� �c6��Sr~��������EWp��bG��U�nP��D��a�����R�.N��2�������T1n~��x�h���@�Fa���@� ���J0�(76 i�,��"Ce�\�Z�V*��D'հ3�M~��-��~��uW7��p%#�liғ�<�PKt������8��C����[~��GǳIų�}w�?���$)��ל�Cј�U���#�)�C�iF�MGu�<b�g�ejq���K�c���g+0`� C��"��&�M�/�Vl�UWG7���`s�˺���  �R�>Y�`q6���c���ot�8U���RBڲb�Pf
Ή_k����r��4�k��1w,.?�'ۂެڎ�l���M5ʣ/�N���MF��x�	�k���?��IR���N����@`Z��6�k���g��!������������[V�����������������]W�{���嶊���?���O����Kה�T�WZ���t��b�ZQ���B].��+*���-v�J���ط��w�נ\'�ߙ%�x���o��	��o�Z�����x�W���庣�h�{�Æ4�9�pp��uz�v������u�R)���oo(�N�z��%��u~��l�"K+4@(��6)%gÔ�?���x��S���e�v�J�1��Er��)�'&�W��fle�*֖q����	�KB*��ٻo�](�l8�r��@B���g$��/l܀[�������s�b�����r��ީ�gݪ��a���������\,e2�'r9|B�'!�|(��%M�Uqy�j@^��_�"�+������l��J��K��c&�t����<+��e����Z�*�������&P;��7�G6B{lQ�<���Z(b�^��tྦ:\��*qɳ��W�B�ߓ�X����}�̣{a�yl}rl����D ������[���Ů#�w�_w�9������a��y���D������:�[����>��sVGב)��#SB�Bj��u����)l{9���^�goX��U��*;����.�bϝLDב3G���*8����8Eg��c�����{��Yxfz�38���Ao��L.��ѩ���[��v�\��fۓ{ޑ���}�a��(�\��sp1����A3�� |�iT!�(�[:�-�l�N�H'7I'��ɵ�ɕ�ɥ҉U:Y�O�6�
t�pt�']��]�c5]�Ѻ���n{�ѩ�����T��\iy��+�-݀�t��ߧ���Z5q���TM,Q����T<�D�����.��wut׏9�aݰ�n{b:.Nǭuݻ�껞��B{��>�8��U��{_�gA�O����vt=6̚��X�3MMWǣ��u��c��'�b��x&���F�����̃�q:��	vZU���H���'Q���C����wrvC_�=��6k�A!��n.X�Td�P6^�r.�a�C�Ķ�MVq�amǐ�c���Q6�]��$\x]wi�YG�k�4��>Sϛ���Cp*��0�N��\f��uw2�IlzX�8�4Ⳏ����M ��i��N��g��Ԃ��Dk��_H�4�eT�g~	4��)h�'�*��Fs3��P��/KHHG�g,���B��_!���m��R��@I����ǆ�Y-��F��:3�����1�����|R��O�.4���~D��N���o�b���pm/]�fF]�}�n=ܔ�j�cd=xxQ�� 8L���ႇ�����a�S���l;�l��G
>{����zPI�8��^ؓ�W��A;h��G�~��z�x���b��Ÿ �jyx�6r �R��}Hg��F��6ʡU��jlf\R�8S�w��c� ���Ҏ*r&t�J��l��O+.� � �!N3�ac�b���z̐�1��.K��g��GD<u1l[�W%퍥�^�7&ioL��j/����\��ɥ���V��T)����L����W,�V��D�8�d��ҹ���D��D���dp$pi#p	����#pi$pq�8epq���]�N\zp�c�Ҩ���,ۓ�e��Np�f�9�@;@�nԂLrǐ�cP�1���H�8 km!�iӢ� �i𬼕j� 2��}��=�SAw1�ef%c��:E%�F� �ó��F33#ZG0/Z�1*�2��v	�&�z�AX�G
a�FVAX#AX�adb=�v5��N#��fV l��$a4h�<`*���I	���e�a���uca��Ax���2��I����+R�E-T�̪�<% �ܱP��Պ	�Z2�u��[�9�)�����f��L���&��O6�d�L� H�s�����3�>�`6dl��ȵ��I�J9�\1��H ��@�J g�AΪ�*�
�9���@n���_���J���r�k\hn��󶏷���$m,�b]rǠ�c@�ѯ���v�j;:�{�����ڊ	/+�x������<��W���M(� `�?6R�"��>�}��7PؑmZo͑J�d�x�C�i���)7O��ߕ��JB�r��~�!������40��� l�u#��v(-�e�C*���{��8؎K`;.lS��2[r\����g�--��������l'��)`;�</Ҡ4h�����'=/:4`{c6���p���fEƦџ�Mj2�yq;ۑlG8&Ew:�,�ޫ��}<O�!�_��#$�I��ԭZ�ä2��2ڄZ�UOQh!H�����3��e��^l��%hw���s�*)�Y;ڦɑ��V�#�O�J�ԧ�O���$��ia���tϳ�PO�(����{U�JjP�25�e��`�}�L��kz&�g����Yj0�>K��� �4����yJj`UR�B��D95�b�RHJ:�(5�3H�y��ж�p�$�O���v�i;z��ڎ��� ����;I�� M�J���oڔd���&�A9V����}��8c�Gaz�gR�a_�43�g�t��A�3�}A�����~`�Ԡ4���t��F���@Z�����>�������g��Ý��>eޔ�s�׍�<#�-��>�`P�}��M0�?�C�?��y�o�A �^֎.�s1C�76��m2%�K�!CE��]��	�w+��T9w��ٙ���x�C8�!]2��==���^��w�&ęJ��H�$�/��fY��3�s����&�OQd�;;U���������苞�2f�&�D@�K�q9�Q�iDYð�)v1�ZO�3	�cs}�#�{�:��ҥ]����*h�sJ�Ie���'Tkϣ�i"��Y���;��r#���'	)�*ʓȾ#0~h��1ʓF)O�<iXΓ��y˳(O�z_Γ%O�cyҨ:Oz�<�%r*y�k�Q��B�y����P9x�{�e�;9�3 %�j���>mG���S�Ѯ�`�u��R����S&��fR�J���s&nX��T2�b#�\�存���Yg�I�fRc晔rif�Ԩ�/�=��e�I�	�Lj�"e��XD���LJH�I�fR�i3���2��4�ԨQ&5�ʤF)�"�e�%{DJ�I�УL��&�Z��2�	%�P2)��M0U&��Z�>��I���L���,�����ӭ���)�W�h�����25�Է��)m.@�ɧ�#�C��*���S�w2�k�I��b�8al��iM�=#�lW����#�$%�Li��31���&��`�g&$'D�,k������q�8�N���զ��jP}���J�Nm�1ɺ��X7b���ԴM��QӴ��d����f��wڴ�'`r��{6�u:giW��M�,�X�~姑p�i�a�<�}�x�:m��4��aPɠu_��r�3��0m>7�զ�<8��\���P�+����aTO��.�o��@��S{��-QM"�5�����U��&�����>��=V?R�Nz�8��@�*S�w77�ɳ�ΑH	��[S��T߂�ǐo���?�GyRғO��D���ttb_�G�$?�'{��Ã�}ϻ��.�I��l{�(خ�GϮ�ڮ��v��#��Zݏ�!8>IS�Mt=���IcG���X��o4����^V��$���3���w�r�'�������I���ÿ����Y�͞I�	~n��������.��ԋ��
9��U��R�H��zE��Ts'��Ǝ��)��X`"��q�@Yŷ��a���D��W�T,['��*�X�Ʉb��<�<%�ÍL��؟3Cdjӫ1��&R��Q���߀��|@���?k�Zn6������z����z(�Z�M�er����2?g�̴!�/T�>/J��Y���&�<��a�
Fz'I��7������:����l�@OU1W��\a}\����:��Q�#x�]U�e�z�oZ�B�¬�*u���$��m���Ӕ�g(E�K��<X�8����@�m�CY.m#(�5L�Ɨ��������dK� �a(��������
U�h����c�P��eUP}F�>�P뙢� �dH���i�*�A�:�� G�%]��)riV� �c�P1���$,�O��琈�<N�IF%g����$"f�2��qS�u��ך�6�����4/�Sg��%���5��f��}t<�N�f����*N��f[��Og�j��� �|x�����	����SP���u�x"U N⠹��~\)Tc�������<9e�4��d���D��=X��iAߜm��t�\P��ݮD�|}/U,�v�����S6����\�1�5Ðo�S�(A�0��O���ab*w�G���<���|t�ӎ΂����������FAC'�j<�s{Z荼R��g�����X(V^4,�^zo:�>Wz��"��c���EV�* s��^/2AP<����wC��Ă"Gz��"��>����z��ƕH��f/QVJWhİ�M1��L��G%��կy�%<���������w��3�QC���� o4S�6����]:����{v�6�źda^/�E9�-���R�Đ�N�o�/+_cu����&~���R��Ԕo���~��9�fS��:�g�S��η���Y�|�'a����xo��+�[�_�s���Z� ����~k�7���ܲ��}"ό�<-�I�E�|ŋ���/��]���}���3��%Z�:��|7���:�>�6��1�۫��!�Uq�7M��n�� |y��5S����VÕ�3ķ�t��t��>�wܔ�i��peߙ���E�R��ZM�kэ�$G&�#���|{t|5�7�����0�s�c�|���� �{�Wc�w���u೾7s�*W��%�
��l�����ݙ���k�|���֍7
|�wg���8S��|�7��;3�K�:g1ޣ��|gfzY�������h���۩�N�;���r�����kk��ۛ����Կ|3�n���n��S����~W5�����o����*�����_}3���L�=��F���H�7Q�7Q�M�ˍ��������'�S�'����������Z%���J�ϫ�����x=�}�/[G�����*����������k��Z�c-����+˨M�?^J���R������Q��F��٨�3k�	��}	�?_���Y������u����>������x��������J��u-�˿��]��9XT��h�*�nԢ?_A�]���χ�r�O_E��/��
h/�; �j����.޶�v?oo���W0s.��
�g!o��V��Dj���H��'	���ˉ>q9��.��Rh?􏊈~ڏ��'h���R��Kٻl���Ҽx�����y[�[o!����h^��}�����0o�ۿ������������BW�=-t}�B��;K���¥���4�[y[��5����������Zz!lѯh>���Ox�$o
h���ܺ�P>�1haJE7-�y�Q���łp��9�0tQ�b�
�Zy;���s�g�'o_����H�sy�]�E���khajE���<nʡ�Jh����$�;��o�Ku�;]��-�~��Y읮E��B#y����[�J�ka�.�{�θ?�nآG,�}�E}����w��ga�-:-��������[�da��-�l�(����I[t?o={W�uv�\w-a�u� \p/��Z�m��\(���؂���q[p���\��?���4��2��8�-�W~1��EW��![��!Nc����il������ct���<<�hl����9�-�_~��E��q[����,�����4�`7�����&��il�^�9]Hv�?a![���Ncv��4�Z+9��J4INc{�#��b���4��@��4�`��"������� Ky���`T�9�{�_@?�V�K���[8]�M�����>��/p��|�^Ns�~N���NN�9}��}�޸��aN����i�xt��uD����*�޷��/�U6N����:9��������eD��ߺ���l��yq�͜�Jz}��D?��h������＞�yD�x��_x��qy�o,���o��至�������E�ory�o"� �7ȿP(���mѯry/ۉ�1޿@yo�&�{��W�� .�rO8�9�4�����-��pz�B����wp�l�=���?�Or~�<!���R�S!$$����I�%}��~PC�TC�-+�u;�ݺ���
�BaW0lC�P��q���>�+���Os��M}�/���n�������H�a�bW ���DЖbpy�ܮXK$t�����X�;��AW��k1(<��n�h
*̾ �9�^8�����S	���Y�
�����J\�ְ�9XR~�sT�
l^�ҵ�Ѳ�����B�DQk�PQ�����Q�\�l��,cN�\6�z.�*XQ�f��ҹP{�\��t�^:gj/�C���m�l�\(�6ʶ́�ms�l�*�C)�5��P�+-�(�b��HY��Զ~�R��l��r�VZQVQ:_���8�u��'P�Zm��:����dg�׵��t.�H?������rj�:YH'՞��Ɋ��MQSya�W�T���)��S��\-�@�gT��a.o��N=��u�&��*�+���x���T���u�R�ɲrO��d!�-�h'����US��ZuA��1����<�W�PkS(�ulM��h��p��:V.��P,�N�����g /OE�\w��Y��J���s[��Qo&��v�-��Zi�%��0/xf����e��r-�\�TE��X�>�_	m\.�/����n'9���[�+�)d)��:�����}�Ж�\O���zb�Fo�#�>ei��|��ٴ�G����󑺽û�w�q�lmX�>x�t�}ֲJH����e1�_F���ģ�5���X
����xP7�݀gј�s�%�$$��a�f���RP���(�2I�t���7P��MjF��$>�y����z<��j�k�^GI�JN�>����1����1����1����1����1����1�3?�Į#�w�_w�9����s�c����爫�ӹ�ܭ����?n��>��O�o`�:��L9��bR����O������2��3��p�8{� ��U`�����*XZ���VY�8"^(�
PSw2]G�=r&���W@;{��Y
�uHg��X�=r_���pRp?����~&�Ӑ�S>����5��9GO.�w��9Y�ʅ��wB�elz��r�w��7��i��<��A�~�Q��x`Χ�p�Y<�'?���p�{<�'�xr�\+?]'��Z8ى'W�IO.����+���'XO�;�~��U�ӄ�+>���5���鲏�u�w��N�<�������J��5㟭����t�C���* �Cg�Z �<�� ��Ŝ�ɾz'� �W��^8�:�o�O���JD!�ph�㻬��>�}d��]?�^M���t$���t�Z׽k����.�������X{��D�,(�IV_��1�
����k�z��5]��e������O���J�Se����)%Ǖ�Ji�+M���D?��ז�%�p|"����p�r.�a��*��l��6MX_!*u�JCrGuv�<J%QaI��n����4�/��r�T���=��@����į7�J��A�=
�:�JT�K��L^��{���yr9�S{񿭗*�I���f�Q&���h����"Mż6�4)|�{�&��(��u�bXm�G���X.�j��`���Jmf=ܔ�ʏ�U��M�k�d�z���ሺ\��/�P�\OB)��R/@;`�r=�E�zI�z�5�YX�D1s�����*��rd��gm�\M�$���8+���+Z�Q5=-�.�T\̦����\�A.F�
���F�b�W�������0؂t%G��1�dPr�bK�Z������*_(�+��IU+��� \y��9U�k!u9��ר��yQ�g$Q�{�(�:�����U��D�c)������	\Z\��4�8	\�2�8%p)�(�K�.�
��*�����Q.�-�՞.��t��5��E���&*x�m	dx��oK �;��m2R�s�1���H�8 km!�iӢ�Tבo� �&���rUT��a\�f���7r��I��I4//Y��KJ�L��a�7��\vc:k4�0�0�uS����r)#k� l� �7�5���n�-�5AXXa�a�
������B���:� ,/�AXX��I��Ѡ�VT� ��&%K���!�/�)>c�9�!�5�A�Ӗu6��I������(���CJ�8�䎅r�H�VL�֒6w|�*p��W&[�!����r� خHl�:�ԟM�m;�d`�L�T	��<�� �z�������3
��O* �T��eR����I�=%�M�U���	�D�erV9�rV	�֮�@�J9�rN�v3�[����#�Y��\r�q�\�BspKWص�-_��;	�x��ޔ��w��M�uR���/w��:���PG���%����YF��j+&����T��A��x��U�	� la��F╡���\r����B���¤�+
ӗw͑J�4����)77-�Z%!�9�
�g?�i]C���� l�u#��v(-���6��l�T`kT�u�Y��6�.#�%�e�]�>{li��lgʻ>N`kS�vXy^�A;h��S�mhNz^th���l[���:o3̊�Mì֟�&5��򼈅]��H�#���J��^%O�3*�H>b�$��
�i|VҪ;u���0��!��6���q��T��JL��ٍ*���.�Ru�^l��%hw���s�*)�Yy)xu�E�ӧ^%}�Sҧ�Wo�b�	���;T%�����U�)PߕP��HB����>O��,��7!M�Ҷ��o'R�25�Q��)��>Iuߩ�,����I��>Fu����cR���5Rj (�A��X�Ԡ��'�u߿�'U�WR��<���,5��e�
H5޻�"@%o�*>�8������W%��O�*>��֫�>�h��9Iy{T��sJ[ս��s�&T���MI��o2�t����7E��-����L`��aU�	��ʥ���I�r�&�-�n
�������������"���t�Ұ��@Z�P��y��` �4��>�*�}�Jh
�Q�L�-��C�nH�{�a����JU�A�i�4y�T��`��`��i`��ս�^֎.�s1C�76��m2%�K�!CE��]��	�w+��T97�H�4p�;.wv�T-��#��M
}�4-��k�|m�n�B�fz5��O'��?���>E��J��T)�2*^�����Z߿ԚW����4,��0/��\2�`�[ԅ��5�(kV��!�.U��)ؠ��F�غ¤���E_����^�um�]�$բ4�9��Ĥ�	e����Q�4a�����kx���;Jn��e%7�}YɍnzYɍJ_Vr��_�ft<q��8��2O��<���1㇨�<ˌ O�<i��a9O��ɫ�<��Y�'M�/�I��'�<iT�'�w�T;[ɓ^;��$�͓�?�0���k�;/���q�� ��(e<�xIʚx�C/IY�8���5��KR��;�^�Y��q+�`�u��R����S&��fR�J���s&nX��T�U*�S���VL��Ŭf�c�+�M2�Q�Lj�<�R.�,�:�����/�^гu����"��r&%�ˤF3����T�*�z�J�L�?M&5j�IM�2�Qʤ�mY&EF��RgR5�(�A.�ɤV�LjBɤ�L��A�L�I���V�$eR|x9��.~!˽�6�t��2�d���-Z#g22�LM>���|J�P�D�)y�H�P��J����~��O�_/�h�I��b�8al��iM�]e�%��I��LR��d���I�4������s�Mr��?��Q�5~O�5�h�>�c�g�jX�T%9ՠ�t�79�n��c�u�,G�n�{��i��ͣ�is����3N��$h�i3O�䴫�l��t*�Ү e��Y(�&��O#a����'~�Lo%��y����lu�,�iHYà�A�@����:��.3I��j�i3����C��e<�J)3�s�S.��[b1Pr��Ԥ�rKT�R�fp��~6�>�(������bw�#ũ��T�2ཻ��L�Mv�D�L(�0��Ҙʖ�̿��l�K�cȷ�[y���	����ʣ��'�G�o�P=�|B5��N��<A3|QU��6S� d��N:�j�c�@����B�}�$�y�I�wfE�SROU0=�ׅ�Ao�+J���J^N����K
?���_��9NO*)i̔�p�N`�2�E�
���U��o]bV��*�X�Ʉb��<�<%�Í4U�K五#��1�)����D_��*�?w1�K�O���U��Z�_QV=�T��6��b�R�լ��Y�[�e~G�����-�s�/�mșe���E�)�ׄ]}_3�N>��N�0@�I*����af�B���_�P��0��Q }�&� �Ts�������k��+u���RG𼻪����
�oZ�B�¬L��q������:��%��OS����gl6���R��Y�4h\��r(˥m�᷆l�k)m�K��_-�PB�ѥ�����dK� �e�V�&�&���U��E2��Ѫ��e���um]�Q%��R�C�uS}D�I(9H:���p�JiP�����ݩ���q¨�7GIX(�p��W*�<Z07��,�[i.�N�KD�Pe,��J�f�59�m��2��[�ڽ:�#M����sL�R:ui�9�6L�~�De�O/�Hx;���T:�=zd��8M 6��-W��<ն�����h�W����L"���������v�	����SP���u�x"U N�^����;���]d��j������E2ޛ?J�yrʌiB���Չj�"��¢�,�ჰ��<��o�6LJ:j.(��nW"e����*�J
�Wc.�ZH�������xf`.�9
�:s�7�3s����2�Y���d._�0�F�T:J�>�#��jeuhL��s�T�DS���������9���΍9�����QF绳����������ѹ*K�������Y�G�7Y����|�����?��|����X��'?���K�M_�0�����~��Wؿ_c�~��Ȩ�)�N���ƶ��>_� �Z��x��N��<������M��o��y��?>;ȫ�*����������"�?#>����=��_d�/��(�A����1��?���}���ꋵ��b4
�����Ñ���/}܁8�n�=x�����1�;�w7|Q��� ��{H�c�V�= ��h��+xW0t0(��%��G�>1Ԭ�䏊A��@=�Vw���P���ލ7��Q .�Ű�0#,��6���N�b��p�����-��X��&z��1��'぀�����h�������"n W�6������=;K��b]�0���jUc�h��8��I.���N�o�/+K��� �Fh��_F>,鲁����a��2ηٔo�������η���Y�|����@|��n�r��E�w�3���|��'�﷦|:���-�x��>�g�wI���$��5J|ŋ���/��]���/���K��:�h����_����N�X����!>�)�^�0~�?��M��;�ۿ? ��^!��L�~��[W����֘�s�n�^���U�;n�����a���k3_ߋp�K	�k5�E7�ȅv��������� ���w��w��׉�)�gt|? ���Wc�w���u�k{s��~<�\�;�0Ϧ���O�|�/ �;���t�պ�F����k�zɁ�s�����F������'�0���ϼ=3��;�u�y�o_4�}�h������1����1����1����1�IK����t+�U.�^��p�ݶ��i~Xz�?�n�}Vy��h,��j�����>�\F�3���m��ʵu{����._��
���1�W��0�Z0lC�P��q���>��������~��[��[��;���
���]��H蠫��u�#�!�+�l�X��PXP*��R��w5G|>�W��*+C��kv�1&���E������%���[�N�����op5����[����7�a��a��]�e�����&�g?��i2:r�,[@x��sp��@��n��=Y���Y��<�o=�<~�tV48���PLi^ V��x+ʝ��&6
��#7�?'🇪���l�����T�^6�u|�9��;N�W{�w�B��Ƚ�bu�枬w-/-���m����S�f�iy����oZ����ǲ��{�����3懝Y����֓_�r�y��l���蝜�'�_���o%�W�~a��s���N�[8��]D�ӿ���8]�����D�!�0��?E���nk��]@t�N����7��5N?�"�MN��G��������8m�}��v��eyD��#��H�&�����s�WEt��]N�.N_y���X$���>���wN/���-D�]C�6N*&��ӏp�>��z����B�$}h�����z�ۥo��mz�/��Ζh\&.��>W��j�\C��V��G ���BH\���1w�Ej ���l�8ˠ����:���j8�P��3A�pX��R�����P��Cf�]%�Pk��,�́��9�QvV���sR:B�d9k����:97!�s!�l.��=WOV̜H*�3Ies&i��T~�X���9�U:����P��9��t_W	H�@Z�?������4_X�o� ư�l�+*D֮��VVN-?�ҵ�֗V�[[Zam��+l�X�'VZR��M.��L�wp�!��}p[s��u����c��?�?����v� & 