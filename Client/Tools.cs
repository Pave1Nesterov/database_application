using Npgsql;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Client
{
    internal class Tools
    {
        public NpgsqlCommand cmd = new NpgsqlCommand();
        public NpgsqlDataReader dr;
        public Tools(NpgsqlConnection conn)
        {
            cmd.Connection = conn;
        }
        public bool makeQuery(string query)
        {
            if (dr != null) dr.Close();
            cmd.CommandType = System.Data.CommandType.Text;
            cmd.CommandText = query;
            try
            {
                dr = cmd.ExecuteReader();
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Ошибка!", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
            return true;
        }
        public DataTable displayQuery(string _query)
        {
            DataTable dt;
            bool value = makeQuery(_query);
            if (!value)
            {
                return null;
            }
            if (dr.HasRows)
            {
                dt = new DataTable();
                dt.Load(dr);
            }
            else return null;
            return dt;
        }
        public int checkPrivileges(string _user)
        {
            string[] liberty = { "postgres", "admin", "moder_1", "worker_1" };
            for (int i = 0; i < liberty.Length; i++)
                if (_user.Contains(liberty[i])) return i;
            return -1;
        }
    }
}