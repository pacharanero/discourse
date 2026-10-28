import EmberObject from "@ember/object";
import type { ReportPayload } from "discourse/admin/models/report";
import type { VersionCheckPayload } from "discourse/admin/models/version-check";
import { ajax } from "discourse/lib/ajax";

const GENERAL_ATTRIBUTES = [
  "updated_at",
  "discourse_updated_at",
  "release_notes_link",
] as const;

/** A dashboard section; plugin loaders supply arbitrary `data`, and a failed section sends `error`. */
export interface AdminDashboardSection {
  id: string;
  data?: unknown;
  error?: boolean;
}

export interface AdminDashboardProblem {
  id: number;
  priority: "low" | "high";
  message: string;
  identifier: string;
}

export interface AdminDashboardGeneralAttributes {
  updated_at: string;
  discourse_updated_at: string | null;
  release_notes_link: string;
}

/** Each loader populates a different subset. */
export interface AdminDashboardFields {
  version_check?: VersionCheckPayload;
  sections?: AdminDashboardSection[];
  configuration?: { sections: { id: string; visible: boolean }[] };
  problems?: AdminDashboardProblem[];
  reports?: Partial<ReportPayload>[];
  attributes?: AdminDashboardGeneralAttributes;
  loaded?: boolean;
}

// eslint-disable-next-line @typescript-eslint/no-empty-object-type, @typescript-eslint/no-unsafe-declaration-merging
export default interface AdminDashboard extends AdminDashboardFields {}

// eslint-disable-next-line @typescript-eslint/no-unsafe-declaration-merging
export default class AdminDashboard extends EmberObject {
  static async fetch({
    startDate,
    endDate,
  }: { startDate?: Date; endDate?: Date } = {}): Promise<AdminDashboard> {
    const data: { start_date?: string; end_date?: string } = {};
    if (startDate) {
      data.start_date = moment(startDate).format("YYYY-MM-DD");
    }
    if (endDate) {
      data.end_date = moment(endDate).format("YYYY-MM-DD");
    }

    // TODO(typescript-pending): ajax has no response generic; remove this assertion when it does.
    const json = (await ajax("/admin/dashboard.json", {
      data,
    })) as AdminDashboardFields;
    const model = AdminDashboard.create();

    model.setProperties({
      version_check: json.version_check,
      sections: json.sections,
      configuration: json.configuration,
      problems: json.problems,
    });

    return model;
  }

  static async fetchGeneral(): Promise<AdminDashboard> {
    // TODO(typescript-pending): ajax has no response generic; remove this assertion when it does.
    const json = (await ajax(
      "/admin/dashboard/general.json"
    )) as AdminDashboardGeneralAttributes & {
      reports?: Partial<ReportPayload>[];
    };
    const model = AdminDashboard.create();

    const attributes = {} as AdminDashboardGeneralAttributes;
    GENERAL_ATTRIBUTES.forEach(
      (a) => ((attributes as unknown as Record<string, unknown>)[a] = json[a])
    );

    model.setProperties({
      reports: json.reports,
      attributes,
      loaded: true,
    });

    return model;
  }

  static async fetchProblems(): Promise<AdminDashboard> {
    // TODO(typescript-pending): ajax has no response generic; remove this assertion when it does.
    const json = (await ajax("/admin/dashboard/problems.json", {
      type: "POST",
    })) as { problems: AdminDashboardProblem[] };
    const model = AdminDashboard.create(json);

    model.set("loaded", true);

    return model;
  }
}

declare const moment: typeof import("moment");
