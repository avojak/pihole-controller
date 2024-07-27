/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2024 Andrew Vojak <andrew.vojak@gmail.com> (https://avojak.com)
 */

public enum PiholeController.ServerPrivacyLevel {

    SHOW_ALL = 0, // Show everything and record everything
    HIDE_DOMAINS = 1, // Hide domains: Display and store all domains as "hidden"
    HIDE_DOMAINS_AND_CLIENTS = 2, // Hide domains and clients: Display and store all domains as "hidden" and all clients as "0.0.0.0"
    ANONYMOUS = 3; // Anonymous mode: This disables basically everything except the live anonymous statistics

}