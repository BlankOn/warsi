/* warsi-exceptions.vala
 *
 * Copyright (C) 2011  Aji Kisworo Mukti <adzy@di.blankon.in>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 */

public errordomain WarsiArchiveError {
    ARCHIVE_OPEN_ERROR,
    ARCHIVE_WRITE_HEADER_ERROR,
    ARCHIVE_FINISH_ERROR,
    ARCHIVE_CLOSE_ERROR
}

public errordomain WarsiCatalogError {
    CATALOG_OPEN_AVAILABLE_ERROR,
    CATALOG_OPEN_STATUS_ERROR
}

public errordomain WarsiDatabaseError {
    DATABASE_PREPARE_ERROR,
    DATABASE_INSERT_ERROR
}
